package spine.openfl;

import spine.openfl.SpineCacheData.SpineCacheFrameData;
import spine.utils.SkeletonClipping;
import spine.attachments.ClippingAttachment;
import lime.utils.ObjectPool;
import openfl.geom.Matrix;
import openfl.display.TriangleCulling;
import openfl.display.BitmapData;
import openfl.display.Sprite;
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
import spine.support.graphics.TextureAtlas;
import spine.attachments.RegionAttachment;
import spine.support.graphics.Color;
import openfl.events.Event;
import spine.openfl.SkeletonSpriteBatchs;
import spine.utils.VectorUtils;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import zygame.utils.SpineManager;

/**
 * Sprite渲染器，单个Sprite会进行单次渲染
 */
class SkeletonSprite extends #if !zygame Sprite #else DisplayObjectContainer #end implements spine.base.SpineBaseDisplay {
	/**
	 * 资源索引
	 */
	public var assetsId:String = null;

	/**
	 * 缓存ID
	 */
	public var cacheId(get, never):String;

	private function get_cacheId():String {
		if (this.skeleton.skin != null)
			return assetsId + ":" + this.skeleton.skin.name;
		return assetsId;
	}

	/**
	 * 切割器
	 */
	private static var clipper:SkeletonClipping = new SkeletonClipping();

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
	public var smoothing:Bool = false;

	/**
	 * 着色器定义，默认为SpineRenderShader
	 */
	public var shaderClass(get, set):Class<SpineRenderShader>;

	private var _shaderClass:Class<SpineRenderShader>;
	private var _shaderVersion:Int = 0;

	private function get_shaderClass():Class<SpineRenderShader> {
		if (_shaderClass == null)
			shaderClass = SpineRenderShader;
		return _shaderClass;
	}

	private function set_shaderClass(shader:Class<SpineRenderShader>):Class<SpineRenderShader> {
		_shaderClass = shader;
		_shaderVersion++;
		return shader;
	}

	/**
	 * 批渲染对象
	 */
	public var batchs:SkeletonSpriteBatchs;

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
	private var _isPlay:Bool = true;

	private var _isDipose:Bool = false;

	/**
	 * 当前播放的动作名
	 */
	private var _actionName:String = "";

	/**
	 * 顶点缓存
	 */
	private var _trianglesVector:Map<AtlasRegion, Vector<Int>>;

	/**
	 * 精灵表垃圾池
	 */
	private var _spritePool:ObjectPool<Sprite> = new ObjectPool(() -> {
		return new Sprite();
	});

	/**
	 * 所有顶点数据
	 */
	private var allVerticesArray:Vector<Float> = new Vector<Float>();

	/**
	 * 所有三角形数据
	 */
	private var allTriangles:Vector<Int> = new Vector<Int>();

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

	/**
	 * 所有UV数据
	 */
	private var allUvs:Vector<Float> = new Vector<Float>();

	/**
	 * 顶点数据索引
	 */
	private var _buffdataPoint:Int = 0;

	/**
	 * 渲染的精灵对象
	 */
	private var _shape:Sprite;

	/**
	 * 是否使用缓存渲染，如果使用缓存渲染，如果使用换成渲染，则无法正常使用过渡动画
	 */
	public var isCache(get, set):Bool;

	private var _isCache:Bool = false;

	private function set_isCache(value:Bool):Bool {
		_isCache = value;
		return value;
	}

	private function get_isCache():Bool {
		return _isCache;
	}

	private var _cacheBitmapData:BitmapData;

	/**
	 * 创建一个Spine对象
	 * @param skeletonData 骨骼数据
	 */
	public function new(skeletonData:SkeletonData) {
		super();

		skeleton = new Skeleton(skeletonData);
		skeleton.updateWorldTransform();

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
		this.addEventListener(Event.ADDED_TO_STAGE, onAddToStage);
		this.addEventListener(Event.REMOVED_FROM_STAGE, onRemoveToStage);
		#end

		_shape = new Sprite();
		this.addChild(_shape);

		_trianglesVector = new Map<AtlasRegion, Vector<Int>>();

		this.mouseChildren = false;
	}

	/**
	 * 统一的渲染入口
	 */
	public function onSpineUpdate(dt:Float):Void {
		advanceTime(dt);
	}

	#if zygame
	/**
	 * 当从舞台移除时
	 */
	override public function onRemoveToStage():Void {
		SpineManager.removeOnFrame(this);
	}

	override public function onAddToStage():Void {
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
		if (isCache) {
			if (__getChange()) {
				GlobalAnimationCache.clearCacheByID(this.cacheId);
				_lastAlpha = @:privateAccess this.__worldAlpha;
			} else {
				var id = __getCurrentFrameId();
				if (id != -1) {
					// 检查是否存在缓存
					var cacheData = GlobalAnimationCache.getCacheByID(cacheId);
					var cacheData2 = cacheData.getFrame(this.actionName, id);
					if (cacheData2 != null) {
						this.renderCacheTriangles(cacheData2);
						return;
					}
				}
			}
		}

		renderTriangles();
	}

	/**
	 * 渲染缓存三角形，使用isCache=true时可正常使用
	 */
	private function renderCacheTriangles(data:SpineCacheFrameData):Void {
		var max:Int = _shape.numChildren - 1;
		while (max >= 0) {
			var spr:Sprite = cast _shape.getChildAt(max);
			spr.visible = false;
			_spritePool.remove(spr);
			_spritePool.add(spr);
			max--;
		}
		if (_cacheBitmapData == null) {
			for (slot in skeleton.drawOrder) {
				var region:AtlasRegion = null;
				if (Std.isOfType(slot.attachment, RegionAttachment)) {
					region = cast cast(slot.attachment, RegionAttachment).getRegion();
				} else if (Std.isOfType(slot.attachment, MeshAttachment)) {
					region = cast cast(slot.attachment, MeshAttachment).getRegion();
				}
				if (region != null)
					_cacheBitmapData = region.page.rendererObject;
				if (_cacheBitmapData != null)
					break;
			}
		}
		var oldTriangles = this.allTriangles;
		var oldTrianglesAlpha = this.allTrianglesAlpha;
		var oldTrianglesBlendMode = this.allTrianglesBlendMode;
		var oldTrianglesColor = this.allTrianglesColor;
		var oldUvs = this.allUvs;
		var oldVerticesArray = this.allVerticesArray;

		this.allTriangles = data.allTriangles;
		this.allTrianglesAlpha = data.allTrianglesAlpha;
		this.allTrianglesBlendMode = data.allTrianglesBlendMode;
		this.allTrianglesColor = data.allTrianglesColor;
		this.allUvs = data.allUvs;
		this.allVerticesArray = data.allVerticesArray;

		drawSprite(null, _cacheBitmapData);

		this.allTriangles = oldTriangles;
		this.allTrianglesAlpha = oldTrianglesAlpha;
		this.allTrianglesBlendMode = oldTrianglesBlendMode;
		this.allTrianglesColor = oldTrianglesColor;
		this.allUvs = oldUvs;
		this.allVerticesArray = oldVerticesArray;
	}

	private var _lastAlpha:Float = 0;

	private function __getChange():Bool {
		return @:privateAccess this.__worldAlpha != _lastAlpha;
	}

	/**
	 * 渲染实现
	 */
	private function renderTriangles():Void {
		var clipper:SkeletonClipping = SkeletonSprite.clipper;
		clipper.clipEnd(); // 清理遮罩数据
		_buffdataPoint = 0;
		var uindex:Int = 0;
		var drawOrder:Array<Slot> = skeleton.drawOrder;
		var n:Int = drawOrder.length;
		var triangles:Array<Int> = null;
		var uvs:Array<Float> = null;
		var verticesLength:Int = 0;
		var atlasRegion:AtlasRegion;
		var slot:Slot;
		// var r:Float = 0, g:Float = 0, b:Float = 0, a:Float = 0;
		var bitmapData:BitmapData = null;

		var v:Vector<Int> = null;

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
		allTriangles = new Vector<Int>();
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
					verticesLength = 8;
					region.computeWorldVertices(slot.bone, _tempVerticesArray, 0, 2);
					uvs = region.getUVs();
					triangles = _quadTriangles;
					atlasRegion = cast region.getRegion();
				} else if (Std.isOfType(slot.attachment, MeshAttachment)) {
					// 如果是网格
					var region:MeshAttachment = cast slot.attachment;
					verticesLength = 8;
					region.computeWorldVertices(slot, 0, region.getWorldVerticesLength(), _tempVerticesArray, 0, 2);
					uvs = region.getUVs();
					triangles = region.getTriangles();
					atlasRegion = cast region.getRegion();
				}
				// 裁剪实现
				if (clipper.isClipping()) {
					clipper.clipTriangles(_tempVerticesArray, _tempVerticesArray.length, triangles, triangles.length, uvs, 1, 1, true);
					if (clipper.getClippedTriangles().length == 0) {
						clipper.clipEndWithSlot(slot);
						continue;
					} else {
						var clippedVertices = clipper.getClippedVertices();
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
						writeTriangles = clipper.getClippedTriangles();
					}
				} else {
					writeVertices = _tempVerticesArray;
					writeTriangles = triangles;
				}

				// 矩形绘制
				if (atlasRegion != null) {
					if (bitmapData != null && (bitmapData != atlasRegion.page.rendererObject)) {
						isFill = true;
					} else if ((slot.data.blendMode != BlendMode.additive && slot.data.blendMode != BlendMode.normal)) {
						isBitmapBlendMode = true;
						isFill = true;
					} else {
						bitmapData = cast atlasRegion.page.rendererObject;
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
						allVerticesArray = new Vector();
						allUvs = new Vector();
						t = 0;
						uindex = 0;
						_buffdataPoint = 0;

						isFill = false;
					}

					bitmapData = cast atlasRegion.page.rendererObject;

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
						allTrianglesColor[_buffdataPoint * 4] = (slot.color.r);
						allTrianglesColor[_buffdataPoint * 4 + 1] = (slot.color.g);
						allTrianglesColor[_buffdataPoint * 4 + 2] = (slot.color.b);
						allTrianglesColor[_buffdataPoint * 4 + 3] = 0;
						// allTrianglesColor[_buffdataPoint * 4 + 3] = (1);
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
						allVerticesArray = new Vector();
						allUvs = new Vector();
						t = 0;
						uindex = 0;
						_buffdataPoint = 0;

						isFill = false;
					}
				}
				clipper.clipEndWithSlot(slot);
			}
		}

		// 最后一个，直接渲染
		if (_spritePool != null)
			drawSprite(null, bitmapData);
	}

	private function drawSprite(slot:Slot, bitmapData:BitmapData, isBlendMode:Bool = false):Void {
		if (allVerticesArray.length == 0 || allTriangles.length == 0 || allUvs.length == 0) {
			return;
		}

		// 缓存
		if (isCache) {
			var frameid = __getCurrentFrameId();
			var datas = GlobalAnimationCache.getCacheByID(this.cacheId);
			if (datas.getFrame(actionName, frameid) == null) {
				var frame = new SpineCacheFrameData();
				frame.allTriangles = allTriangles.copy();
				frame.allUvs = allUvs.copy();
				frame.allVerticesArray = allVerticesArray.copy();
				frame.allTrianglesAlpha = allTrianglesAlpha.copy();
				frame.allTrianglesBlendMode = allTrianglesBlendMode.copy();
				frame.allTrianglesColor = allTrianglesColor.copy();
				datas.addFrame(actionName, frameid, frame);
			}
		}

		// 往批处理上传数据
		if (batchs != null) {
			batchs.uploadBuffData(this, allVerticesArray, this.allTriangles, this.allUvs, this.allTrianglesColor, this.allTrianglesBlendMode,
				this.allTrianglesAlpha);
			return;
		}

		var spr:Sprite = _spritePool.get();
		if (slot != null && isBlendMode) {
			switch (slot.data.blendMode) {
				case BlendMode.additive:
				// 内置Shader支持
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
		var _shader:SpineRenderShader = cast spr.shader;
		if (_shader == null || _shader.shaderVersion != _shaderVersion) {
			_shader = Type.createInstance(shaderClass, []);
			_shader.shaderVersion = _shaderVersion;
			spr.shader = _shader;
		}
		#if zygame
		if (Std.isOfType(this.parent, zygame.components.ZSpine)) {
			_shader.data.u_malpha.value = [this.parent.alpha * this.alpha];
		} else {
			_shader.data.u_malpha.value = [this.alpha];
		}
		#else
		_shader.data.u_malpha.value = [this.alpha];
		#end

		_shader.data.bitmap.input = bitmapData;
		// Smoothing
		_shader.data.bitmap.filter = smoothing ? LINEAR : NEAREST;
		_shader.a_texalpha.value = allTrianglesAlpha;
		_shader.a_texblendmode.value = allTrianglesBlendMode;
		_shader.a_texcolor.value = allTrianglesColor;
		spr.graphics.beginShaderFill(_shader);
		spr.graphics.drawTriangles(allVerticesArray, allTriangles, allUvs, TriangleCulling.NONE);
		spr.graphics.endFill();
		_shape.addChild(spr);
		spr.visible = true;
	}

	/**
	 * 渲染数组转换
	 * @param data
	 * @return Vector<Int>
	 */
	private function ofArrayInt(data:Array<Int>):Vector<Int> {
		var v:Vector<Int> = new Vector<Int>();
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
		var v:Vector<Float> = new Vector<Float>();
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

	public function isHidden():Bool {
		return this.__worldAlpha == 0 || !this.__visible;
	}
}
