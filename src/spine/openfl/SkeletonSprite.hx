package spine.openfl;

import openfl.display.Bitmap;
import spine.atlas.TextureAtlasRegion;
import openfl.display.Shape;
import spine.SkeletonClipping;
import spine.attachments.ClippingAttachment;
import lime.utils.ObjectPool;
import openfl.display.TriangleCulling;
import openfl.display.BitmapData;
import openfl.display3D.Context3DTextureFilter;
#if zygame
import zygame.display.DisplayObjectContainer;
import zygame.components.ZImage;
#end
import spine.shader.SpineRenderShader;
import openfl.Vector;
import spine.attachments.MeshAttachment;
import spine.Skeleton;
import spine.SkeletonData;
import spine.Slot;
import spine.atlas.TextureAtlas;
import spine.attachments.RegionAttachment;
import spine.Color;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import zygame.utils.SpineManager;

/**
 * Sprite渲染器，单个Sprite会进行单次渲染
 */
class SkeletonSprite extends #if !zygame Sprite #else DisplayObjectContainer #end implements spine.base.SpineBaseDisplay {
	/**
	 * 切割器
	 */
	private static var clipper:SkeletonClipping = new SkeletonClipping();

	/**
	 * 资源索引
	 */
	public var assetsId:String = null;

	/**
	 * 最后绘制时间
	 */
	public var lastDrawTime:Float = 0;

	/**
	 * 是否为独立运行，不受SpineManager的影响
	 */
	public var independent:Bool = false;

	/**
	 * 骨架对象
	 */
	public var skeleton:Skeleton;

	/**
	 * 时间轴缩放
	 */
	public var timeScale:Float = 1;

	/**
	 * SpriteSpine的平滑支持，默认为false，可设置为true开启平滑支持
	 */
	public var smoothing:Bool = #if !smoothing false #else true #end;

	/**
	 * 坐标数组
	 */
	private var _tempVerticesArray:Array<Float>;

	/**
	 * 矩形三角形
	 */
	private var _quadTriangles:Array<Int>;

	/**
	 * 颜色数组（未实现）
	 */
	private var _colors:Array<Int>;

	/**
	 * 是否正在播放
	 */
	private var _isPlay:Bool = false;

	private var _isDipose:Bool = false;

	/**
	 * 当前播放的动作名
	 */
	private var _actionName:String = "";

	/**
	 * 顶点缓存
	 */
	private var _trianglesVector:Map<TextureAtlasRegion, Vector<Int>>;

	/**
	 * 精灵表垃圾池
	 */
	private var _spritePool:ObjectPool<Sprite> = new ObjectPool(() -> {
		return new Sprite();
	});

	/**
	 * 所有顶点数据
	 */
	private var allVerticesArray:Vector<Float> = new Vector<Float>(0, false);

	/**
	 * 所有三角形数据
	 */
	private var allTriangles:Vector<Int> = new Vector<Int>(0, false);

	/**
	 * 所有顶点透明属性
	 */
	private var allTrianglesAlpha:Array<Float> = [];

	/**
	 * 所有顶点BlendMode属性
	 */
	private var allTrianglesBlendMode:Array<Float> = [];

	/**
	 * 所有顶点的颜色相乘
	 */
	private var allTrianglesColor:Array<Float> = [];

	private var allTrianglesDarkColor:Array<Float> = [];

	/**
	 * 所有UV数据
	 */
	private var allUvs:Vector<Float> = new Vector<Float>(0, false);

	/**
	 * 顶点数据索引
	 */
	private var _buffdataPoint:Int = 0;

	/**
	 * 渲染的精灵对象
	 */
	private var _shape:Sprite;

	/**
	 * 创建一个Spine对象
	 * @param skeletonData 骨骼数据
	 */
	public function new(skeletonData:SkeletonData) {
		super();

		skeleton = new Skeleton(skeletonData);
		skeleton.updateWorldTransform(Physics.update);

		_tempVerticesArray = new Array<Float>();
		_quadTriangles = new Array<Int>();
		_quadTriangles[0] = 0;
		_quadTriangles[1] = 1;
		_quadTriangles[2] = 2;
		_quadTriangles[3] = 2;
		_quadTriangles[4] = 3;
		_quadTriangles[5] = 0;
		_colors = new Array<Int>();

		#if !zygame
		this.addEventListener(openfl.events.Event.ADDED_TO_STAGE, onAddToStage);
		this.addEventListener(openfl.events.Event.Event.REMOVED_FROM_STAGE, onRemoveToStage);
		#end

		// this.addEventListener(Event.)

		_shape = new Sprite();
		this.addChild(_shape);

		_trianglesVector = new Map<TextureAtlasRegion, Vector<Int>>();

		this.mouseChildren = false;
	}

	/**
	 * 统一的渲染入口
	 */
	public function onSpineUpdate(dt:Float):Void {
		advanceTime(dt);
	}

	/**
	 * 自动启动帧事件更新
	 */
	public var autoOnFrame = true;

	#if zygame
	/**
	 * 当从舞台移除时
	 */
	override public function onRemoveToStage():Void {
		if (!allowHiddenRender)
			SpineManager.removeOnFrame(this);
		#if !final
		else
			trace("Warring:allowHiddenRender is true, not call removeOnFrame.", this.assetsId);
		#end
	}

	override public function onAddToStage():Void {
		if (autoOnFrame)
			SpineManager.addOnFrame(this);
	}
	#else

	/**
	 * 当从舞台移除时
	 */
	public function onRemoveToStage(_):Void {
		SpineManager.removeOnFrame(this);
	}

	public function onAddToStage(_):Void {
		if (autoOnFrame)
			SpineManager.addOnFrame(this);
	}
	#end

	/**
	 * 丢弃
	 */
	#if zygame override #end public function destroy():Void {
		SpineManager.removeOnFrame(this);
		if (_spritePool != null)
			_spritePool.clear();
		_spritePool = null;
		removeChildren();
		graphics.clear();
		_isDipose = true;
	}

	/**
	 * 播放
	 */
	public function play(action:String = null, loop:Bool = true):Void {
		// TODO 是否有必要存在呢？
		if (autoOnFrame)
			SpineManager.addOnFrame(this);
		_isPlay = true;
		if (action != null)
			_actionName = action;
		this.advanceTime(0);
	}

	/**
	 * 是否正在播放
	 */
	public var isPlay(get, set):Bool;

	private function get_isPlay():Bool {
		if (_isPlay)
			return true;
		return false;
	}

	private function set_isPlay(bool:Bool):Bool {
		_isPlay = bool;
		return bool;
	}

	/**
	 * 获取当前播放的动作
	 */
	public var actionName(get, never):String;

	private function get_actionName():String {
		return _actionName;
	}

	/**
	 * 停止
	 */
	public function stop():Void {
		SpineManager.removeOnFrame(this);
		_isPlay = false;
	}

	private function __getCurrentFrameId():Int {
		return -1;
	}

	/**
	 * 激活渲染
	 * @param delta
	 */
	public function advanceTime(delta:Float):Void {
		if (_isPlay == false || _isDipose)
			return;
		renderTriangles();
	}

	private var _lastAlpha:Float = 1;

	private function __getChange():Bool {
		return @:privateAccess this.__worldAlpha != _lastAlpha;
	}

	private function clearSprite():Void {
		var max:Int = _shape.numChildren - 1;
		while (max >= 0) {
			var spr:Sprite = cast _shape.getChildAt(max);
			// _shape.removeChild(spr);
			spr.visible = false;
			_spritePool.remove(spr);
			_spritePool.add(spr);
			max--;
		}
		_shape.graphics.clear();
	}

	/**
	 * 离屏渲染模式
	 */
	public var offscreenRender:Bool = false;

	/**
	 * 渲染实现
	 */
	private function renderTriangles():Void {
		if (!offscreenRender && (!this.visible || this.stage == null)) {
			return;
		}
		var clipper:SkeletonClipping = SkeletonSprite.clipper;
		clipper.clipEnd(); // 清理遮罩数据
		_buffdataPoint = 0;
		var uindex:Int = 0;
		var drawOrder:Array<Slot> = skeleton.drawOrder;
		var n:Int = drawOrder.length;
		var triangles:Array<Int> = null;
		var uvs:Array<Float> = null;
		var atlasRegion:TextureAtlasRegion;
		var slot:Slot;
		// var r:Float = 0, g:Float = 0, b:Float = 0, a:Float = 0;
		var bitmapData:BitmapData = null;

		var v:Vector<Int> = null;

		this.clearSprite();

		allTriangles.length = 0;
		var t:Int = 0;

		var writeVertices:Array<Float> = null;
		var writeTriangles:Array<Int> = null;

		// 是否开始填充
		var isFill = false;
		var isBitmapBlendMode = false;

		for (i in 0...n) {
			// 获取骨骼
			slot = drawOrder[i];
			// 初始化参数
			triangles = null;
			uvs = null;
			atlasRegion = null;
			// 如果骨骼的渲染物件存在
			if (slot.attachment != null) {
				// 如果不可见的情况下，则隐藏
				if (slot.color.a == 0)
					continue;
				if (Std.isOfType(slot.attachment, ClippingAttachment)) {
					// 如果是剪切
					var region:ClippingAttachment = cast slot.attachment;
					clipper.clipStart(slot, region);
					continue;
				} else if (Std.isOfType(slot.attachment, RegionAttachment)) {
					// 如果是矩形
					var region:RegionAttachment = cast slot.attachment;
					_tempVerticesArray = [];
					region.computeWorldVertices(slot, _tempVerticesArray, 0, 2);
					uvs = region.uvs;
					triangles = _quadTriangles.copy();
					atlasRegion = cast region.region;
				} else if (Std.isOfType(slot.attachment, MeshAttachment)) {
					// 如果是网格
					var region:MeshAttachment = cast slot.attachment;
					region.computeWorldVertices(slot, 0, region.worldVerticesLength, _tempVerticesArray, 0, 2);
					uvs = region.uvs;
					triangles = region.triangles.copy();
					atlasRegion = cast region.region;
				}
				// 裁剪实现
				if (clipper.isClipping()) {
					if (triangles == null)
						continue;
					clipper.clipTriangles(_tempVerticesArray, triangles, triangles.length, uvs);
					if (clipper.clippedTriangles.length == 0) {
						clipper.clipEndWithSlot(slot);
						continue;
					} else {
						var clippedVertices = clipper.clippedVertices;
						writeVertices = [];
						uvs = [];
						var i = 0;
						while (true) {
							writeVertices.push(clippedVertices[i]);
							writeVertices.push(clippedVertices[i + 1]);
							uvs.push(clippedVertices[i + 4]);
							uvs.push(clippedVertices[i + 5]);
							i += 6;
							if (i >= clippedVertices.length)
								break;
						}
						writeTriangles = clipper.clippedTriangles;
					}
				} else {
					writeVertices = _tempVerticesArray;
					writeTriangles = triangles;
				}

				// 矩形绘制
				if (atlasRegion != null) {
					if (bitmapData != null && (bitmapData != atlasRegion.page.texture)) {
						isFill = true;
					} else if ((slot.data.blendMode != BlendMode.additive && slot.data.blendMode != BlendMode.normal)) {
						isBitmapBlendMode = true;
						isFill = true;
					} else {
						bitmapData = cast atlasRegion.page.texture;
					}

					// 如果是可以填充
					if (isFill) {
						if (_spritePool == null)
							continue;
						drawSprite(slot, bitmapData);
						// 重置
						allTriangles.length = 0;
						allTrianglesAlpha.resize(0);
						allTrianglesColor.resize(0);
						allTrianglesDarkColor.resize(0);
						allVerticesArray.length = 0;
						allUvs.length = 0;
						t = 0;
						uindex = 0;
						_buffdataPoint = 0;

						isFill = false;
					}

					bitmapData = cast atlasRegion.page.texture;

					// 新增图片颜色更改支持
					var tempLightColor = new Color(slot.color.r, slot.color.g, slot.color.b, slot.color.a);
					if (slot.attachment is MeshAttachment) {
						var slotAttachmentColor = cast(slot.attachment, MeshAttachment).color;
						tempLightColor.set(tempLightColor.r * slotAttachmentColor.r, tempLightColor.g * slotAttachmentColor.g,
							tempLightColor.b * slotAttachmentColor.b, tempLightColor.a * slotAttachmentColor.a);
					} else if (slot.attachment is RegionAttachment) {
						var slotAttachmentColor = cast(slot.attachment, RegionAttachment).color;
						tempLightColor.set(tempLightColor.r * slotAttachmentColor.r, tempLightColor.g * slotAttachmentColor.g,
							tempLightColor.b * slotAttachmentColor.b, tempLightColor.a * slotAttachmentColor.a);
					}

					var tempDarkColor = new Color(0, 0, 0, 0);
					var isDark = false;
					if (slot.darkColor != null) {
						tempDarkColor.add(slot.darkColor.r, slot.darkColor.g, slot.darkColor.b, slot.darkColor.a);
						isDark = true;
						// 	isBitmapBlendMode = true;
					}

					// 补充完毕后仍然需要记录
					for (vi in 0...writeTriangles.length) {
						// 追加顶点
						allTriangles[_buffdataPoint] = writeTriangles[vi] + t;
						// 添加顶点属性
						allTrianglesAlpha[_buffdataPoint] = slot.color.a * @:privateAccess this.__worldAlpha; // Alpha

						switch (slot.data.blendMode) {
							case BlendMode.additive:
								allTrianglesBlendMode[_buffdataPoint] = 1;
							case BlendMode.multiply:
								allTrianglesBlendMode[_buffdataPoint] = 0;
							case BlendMode.screen:
								allTrianglesBlendMode[_buffdataPoint] = 0;
							case BlendMode.normal:
								allTrianglesBlendMode[_buffdataPoint] = 0;
						}

						allTrianglesDarkColor[_buffdataPoint * 4] = tempDarkColor.r * tempDarkColor.a;
						allTrianglesDarkColor[_buffdataPoint * 4 + 1] = tempDarkColor.g * tempDarkColor.a;
						allTrianglesDarkColor[_buffdataPoint * 4 + 2] = tempDarkColor.b * tempDarkColor.a;
						allTrianglesDarkColor[_buffdataPoint * 4 + 3] = isDark ? 1 : 0;

						allTrianglesColor[_buffdataPoint * 4] = tempLightColor.r;
						allTrianglesColor[_buffdataPoint * 4 + 1] = tempLightColor.g;
						allTrianglesColor[_buffdataPoint * 4 + 2] = tempLightColor.b;
						allTrianglesColor[_buffdataPoint * 4 + 3] = 0;

						_buffdataPoint++;
					}

					for (ui in 0...uvs.length) {
						// 追加坐标
						allVerticesArray[uindex] = writeVertices[ui];
						// 追加UV
						allUvs[uindex] = uvs[ui];
						uindex++;
					}
					t += Std.int(uvs.length / 2);

					// 如果是BitmapBlend渲染
					if (isBitmapBlendMode) {
						drawSprite(slot, bitmapData, true);
						// 重置
						allTriangles.length = 0;
						allTrianglesAlpha.resize(0);
						allTrianglesColor.resize(0);
						allTrianglesDarkColor.resize(0);
						allTrianglesBlendMode.resize(0);
						allVerticesArray.length = 0;
						allUvs.length = 0;
						t = 0;
						uindex = 0;
						_buffdataPoint = 0;

						isFill = false;
					}
				}
				clipper.clipEndWithSlot(slot);
			} else if (slot != null && clipper.isClipping()) {
				clipper.clipEndWithSlot(slot);
			}
		}

		// 最后一个，直接渲染
		if (_spritePool != null)
			drawSprite(null, bitmapData);
	}

	dynamic public function onRenderBefore():Void {}

	/**
	 * 是否启动颜色过渡期
	 */
	public var colorTransformEnable:Bool = false;

	private function drawSprite(slot:Slot, bitmapData:BitmapData, isBlendMode:Bool = false):Void {
		if (allVerticesArray.length == 0 || allTriangles.length == 0 || allUvs.length == 0) {
			return;
		}

		var spr:Sprite = _spritePool.get();
		if (slot != null && isBlendMode) {
			switch (slot.data.blendMode) {
				case BlendMode.additive:
					// 内置Shader支持
					spr.blendMode = openfl.display.BlendMode.ADD;
				case BlendMode.multiply:
					spr.blendMode = openfl.display.BlendMode.MULTIPLY;
				case BlendMode.screen:
					spr.blendMode = openfl.display.BlendMode.SCREEN;
				case BlendMode.normal:
					spr.blendMode = openfl.display.BlendMode.NORMAL;
			}
		} else {
			spr.blendMode = openfl.display.BlendMode.NORMAL;
		}

		spr.graphics.clear();
		// todo 这里应该只需要一个Shader即可，无需使用过多的相同的Shader
		var _shader:SpineRenderShader = this.shader == null ? SpineRenderShader.shader : cast this.shader;

		_shader.data.bitmap.input = bitmapData;
		// Smoothing
		_shader.data.bitmap.filter = smoothing ? LINEAR : NEAREST;
		_shader.a_texalpha.value = allTrianglesAlpha;
		_shader.a_texblendmode.value = allTrianglesBlendMode;
		_shader.a_texcolor.value = allTrianglesColor;
		_shader.a_darkcolor.value = allTrianglesDarkColor;
		if (colorTransformEnable && this.transform.colorTransform != null) {
			_shader.u_hasColorTransform.value = [true];
			_shader.u_colorMultiplier.value = [
				this.transform.colorTransform.redMultiplier,
				this.transform.colorTransform.greenMultiplier,
				this.transform.colorTransform.blueMultiplier,
				1
			];
			_shader.u_colorOffset.value = [
				this.transform.colorTransform.redOffset / 255,
				this.transform.colorTransform.greenOffset / 255,
				this.transform.colorTransform.blueOffset / 255,
				this.transform.colorTransform.alphaOffset / 255
			];
		} else {
			_shader.u_hasColorTransform.value = [false];
		}
		onRenderBefore();

		// 缓存
		// spr.graphics.beginFill(0xff0000);
		spr.graphics.beginShaderFill(_shader);
		spr.graphics.drawTriangles(allVerticesArray, allTriangles, allUvs, TriangleCulling.NONE);
		spr.graphics.endFill();
		_shape.addChild(spr);
		spr.visible = true;
		spr.removeChildren();
		var counts = Std.int(allVerticesArray.length / 2);
		// for (i in 0...counts) {
		// 	var s = new Sprite();
		// 	s.graphics.beginFill(0xff0000);
		// 	s.graphics.drawRect(allVerticesArray[i * 2], allVerticesArray[i * 2 + 1], 10, 10);
		// 	s.graphics.endFill();
		// 	spr.addChild(s);
		// 	break;
		// }
		// if (counts == 4) {
		var quad = new Sprite();
		quad.graphics.beginShaderFill(_shader);
		// quad.graphics.beginFill(0xff0000,0.5);
		// quad.graphics.beginBitmapFill(bitmapData);
		var t = new Vector<Float>();
		for (f in allVerticesArray) {
			t.push(f);
		}
		// t.push(allVerticesArray[0]);
		// t.push(allVerticesArray[1]);
		// t.push(allVerticesArray[2]);
		// t.push(allVerticesArray[3]);
		// t.push(allVerticesArray[4]);
		// t.push(allVerticesArray[5]);
		// t.push(allVerticesArray[6]);
		// t.push(allVerticesArray[7]);
		var t2 = new Vector();
		// t2.push(allTriangles[0]);
		// t2.push(allTriangles[1]);
		// t2.push(allTriangles[2]);
		// t2.push(allTriangles[3]);
		// t2.push(allTriangles[4]);
		// t2.push(allTriangles[5]);
		for (i in allTriangles) {
			t2.push(i);
		}
		var u3 = new Vector();
		// u3.push(allUvs[0]);
		// u3.push(allUvs[1]);
		// u3.push(allUvs[2]);
		// u3.push(allUvs[3]);
		// u3.push(allUvs[4]);
		// u3.push(allUvs[5]);
		// u3.push(allUvs[6]);
		// u3.push(allUvs[7]);
		for (f in allUvs) {
			u3.push(f);
		}
		quad.graphics.drawTriangles(t, t2, u3);
		quad.graphics.endFill();
		spr.addChild(quad);
		// }
	}

	/**
	 * 渲染数组转换
	 * @param data
	 * @return Vector<Int>
	 */
	private function ofArrayInt(data:Array<Int>):Vector<Int> {
		var v:Vector<Int> = new Vector<Int>(0, false);
		for (i in 0...data.length)
			v.set(i, data[i]);
		return v;
	}

	/**
	 * 渲染数组转换
	 * @param data
	 * @return Vector<Float>
	 */
	private function ofArrayFloat(data:Array<Float>):Vector<Float> {
		var v:Vector<Float> = new Vector<Float>(0, false);
		for (i in 0...data.length)
			v.set(i, data[i]);
		return v;
	}

	#if !flash
	/**
	 * 重构触摸事件，无法触发触摸的问题
	 * @param x
	 * @param y
	 * @param shapeFlag
	 * @param stack
	 * @param interactiveOnly
	 * @param hitObject
	 * @return Bool
	 */
	override private function __hitTest(x:Float, y:Float, shapeFlag:Bool, stack:Array<DisplayObject>, interactiveOnly:Bool, hitObject:DisplayObject):Bool {
		if (this.mouseEnabled == false || this.visible == false)
			return false;
		if (this.getBounds(stage).contains(x, y)) {
			if (stack != null)
				stack.push(this);
			return true;
		}
		return false;
	}
	#end

	public function getMaxTime():Float {
		return 0;
	}

	/**
	 * 允许隐藏状态下渲染
	 */
	public var allowHiddenRender(default, set):Bool = false;

	private function set_allowHiddenRender(bool:Bool):Bool {
		if (this.allowHiddenRender == bool)
			return bool;
		this.allowHiddenRender = bool;
		if (this.allowHiddenRender) {
			if (autoOnFrame)
				SpineManager.addOnFrame(this);
		} else {
			if (this.parent == null) {
				SpineManager.removeOnFrame(this);
			}
		}
		return bool;
	}

	private var _isHidden:Bool = false;

	public function isHidden():Bool {
		if (allowHiddenRender)
			return false;
		_isHidden = this.alpha == 0 || !this.visible || this.stage == null;
		return _isHidden;
	}
}
