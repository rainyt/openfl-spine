package spine.openfl;

import spine.attachments.Attachment;
import spine.events.AnimationEvent;
import spine.animation.Animation;
import spine.animation.AnimationStateData;
import spine.animation.AnimationState;
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
 * 支持官方Spine-Haxe 4.2+版本的骨骼动画组件
 */
class SkeletonAnimation extends #if !zygame Sprite #else DisplayObjectContainer #end implements spine.base.SpineBaseDisplay {
	/**
	 * 切割器
	 */
	private static var clipper:SkeletonClipping = new SkeletonClipping();

	/**
	 * 矩形顶点
	 */
	private static var quadTriangles:Array<Int> = [0, 1, 2, 2, 3, 0];

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
	 * 骨骼动画状态
	 */
	public var state:AnimationState;

	/**
	 * 当前动画数据
	 */
	private var _currentAnimation:Animation;

	/**
	 * 时间轴缩放
	 */
	public var timeScale(get, set):Float;

	private function set_timeScale(v:Float):Float {
		this.state.timeScale = v;
		return v;
	}

	private function get_timeScale():Float {
		return this.state.timeScale;
	}

	/**
	 * SpriteSpine的平滑支持，默认为false，可设置为true开启平滑支持
	 */
	public var smoothing:Bool = #if !smoothing false #else true #end;

	/**
	 * 坐标数组
	 */
	private var _tempVerticesArray:Array<Float>;

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
	public function new(skeletonData:SkeletonData, stateData:AnimationState = null) {
		super();
		skeleton = new Skeleton(skeletonData);
		skeleton.scaleY = -1;
		state = stateData != null ? stateData : new AnimationState(new AnimationStateData(skeletonData));
		skeleton.updateWorldTransform(Physics.update);

		_tempVerticesArray = new Array<Float>();
		_colors = new Array<Int>();

		#if !zygame
		this.addEventListener(openfl.events.Event.ADDED_TO_STAGE, onAddToStage);
		this.addEventListener(openfl.events.Event.Event.REMOVED_FROM_STAGE, onRemoveToStage);
		#end

		_shape = new Sprite();
		this.addChild(_shape);
		_trianglesVector = new Map<TextureAtlasRegion, Vector<Int>>();
		this.mouseChildren = false;
		this.advanceTime(0);
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
		if (action != this.actionName) {
			if (action != null && action != "") {
				this.state.setAnimationByName(0, action, loop);
			}
			this._currentAnimation = getAnimation(action);
		}
		if (autoOnFrame)
			SpineManager.addOnFrame(this);
		_isPlay = true;
		if (action != null)
			_actionName = action;
		this.advanceTime(0);
	}

	/**
	 * 强制播放切换
	 * @param action 动作名
	 * @param loop 是否循环
	 */
	public function playForce(action:String, loop:Bool = true):Void {
		isPlay = true;
		if (action != null && action != "") {
			this.state.setAnimationByName(0, action, loop);
		}
		this._currentAnimation = getAnimation(action);
		this.play(action);
	}

	/**
	 * 获取最大持续时间
	 * @return Float
	 */
	public function getMaxTime():Float {
		if (_currentAnimation != null)
			return _currentAnimation.duration;
		return 0;
	}

	/**
	 * 获得动画对象数据
	 * @param name 
	 * @return Animation
	 */
	public function getAnimation(name:String):Animation {
		for (animation in this.state.data.skeletonData.animations) {
			if (animation.name == name)
				return animation;
		}
		return null;
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

	/**
	 * 在updateWorldTransform调用之前发生
	 */
	dynamic public function onUpdateWorldTransformBefore():Void {}

	/**
	 * 在updateWorldTransform调用之后发生
	 */
	dynamic public function onUpdateWorldTransformAfter():Void {}

	/**
	 * 激活渲染
	 * @param delta
	 */
	public function advanceTime(delta:Float):Void {
		if (_isPlay == false || _isDipose)
			return;
		this.onUpdateWorldTransformBefore();
		state.update(delta);
		state.apply(skeleton);
		skeleton.update(delta);
		skeleton.updateWorldTransform(Physics.update);
		this.onUpdateWorldTransformAfter();
		if (!allowHiddenRender) {
			if (!this.visible || !isPlay)
				return;
		}
		renderTriangles();
		if (delta != 0 && onRootBoneAnimateChange != null)
			onRootBoneAnimateChange(delta);
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
	 * 应用根骨骼动画
	 * @return Bool 如果返回`false`，则不再应用根骨骼动画
	 */
	public var onRootBoneAnimateChange:Float->Bool;

	/**
	 * 渲染实现
	 */
	private function renderTriangles():Void {
		if (!offscreenRender && (!this.visible || this.stage == null)) {
			return;
		}
		var clipper:SkeletonClipping = SkeletonAnimation.clipper;
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
					triangles = quadTriangles.copy();
					atlasRegion = cast region.region;
				} else if (Std.isOfType(slot.attachment, MeshAttachment)) {
					// 如果是网格
					var region:MeshAttachment = cast slot.attachment;
					_tempVerticesArray = [];
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
						allTriangles = new Vector();
						allTrianglesAlpha = [];
						allTrianglesColor = [];
						allTrianglesDarkColor = [];
						allVerticesArray = new Vector();
						allUvs = new Vector();
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
						allTriangles = new Vector();
						allTrianglesAlpha = [];
						allTrianglesColor = [];
						allTrianglesDarkColor = [];
						allTrianglesBlendMode = [];
						allVerticesArray = new Vector();
						allUvs = new Vector();
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

		spr.graphics.beginShaderFill(_shader);
		spr.graphics.drawTriangles(allVerticesArray, allTriangles, allUvs, TriangleCulling.NONE);
		spr.graphics.endFill();
		_shape.addChild(spr);
		spr.visible = true;

		if (onRootBoneAnimateChange != null) {
			spr.x = -this.skeleton.rootBone.worldX;
			spr.y = -this.skeleton.rootBone.worldY;
		}
	}

	private var __lastApplyRootX:Float = 0.;

	private var __lastApplyRootY:Float = 0.;

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

	private var _event:AnimationEvent;

	override function addEventListener<T>(type:openfl.events.EventType<T>, listener:T->Void, useCapture:Bool = false, priority:Int = 0,
			useWeakReference:Bool = false) {
		if (_event == null && state != null) {
			_event = new AnimationEvent();
			// 添加事件侦听处理
			this.state.onStart.add(_event.start);
			this.state.onComplete.add(_event.complete);
			this.state.onDispose.add(_event.dispose);
			this.state.onEnd.add(_event.end);
			this.state.onInterrupt.add(_event.interrupt);
			this.state.onEvent.add(_event.event);
		}
		if (_event != null)
			_event.addEventListener(type, listener);
		super.addEventListener(type, listener, useCapture, priority, useWeakReference);
	}

	override function removeEventListener<T>(type:openfl.events.EventType<T>, listener:T->Void, useCapture:Bool = false) {
		super.removeEventListener(type, listener, useCapture);
		if (_event != null)
			_event.removeEventListener(type, listener);
	}
}
