// package spine.openfl;

// import spine.utils.SkeletonClipping;
// import spine.attachments.ClippingAttachment;
// import lime.utils.ObjectPool;
// import openfl.geom.Matrix;
// import openfl.display.TriangleCulling;
// import openfl.display.BitmapData;
// import openfl.display.Sprite;
// #if zygame
// import zygame.display.DisplayObjectContainer;
// #end
// import openfl.Vector;
// import spine.attachments.MeshAttachment;
// import spine.Skeleton;
// import spine.SkeletonData;
// import spine.Slot;
// import spine.support.graphics.TextureAtlas;
// import spine.attachments.RegionAttachment;
// import spine.support.graphics.Color;
// import openfl.events.Event;
// import spine.openfl.SkeletonBatchs;
// import spine.utils.VectorUtils;
// import openfl.display.DisplayObject;
// import openfl.display.Sprite;
// import zygame.utils.SpineManager;

// /**
//  * Sprite渲染器，单个Sprite会进行单次渲染
//  */
// class SkeletonSprite2 extends #if !zygame Sprite #else DisplayObjectContainer #end implements spine.base.SpineBaseDisplay {
// 	/**
// 	 * 切割器
// 	 */
// 	private static var clipper:SkeletonClipping = new SkeletonClipping();

// 	/**
// 	 * 骨架对象
// 	 */
// 	public var skeleton:Skeleton;

// 	/**
// 	 * 时间轴缩放
// 	 */
// 	public var timeScale:Float = 1;

// 	/**
// 	 * 批渲染对象
// 	 */
// 	public var batchs:SkeletonBatchs;

// 	/**
// 	 * 坐标数组
// 	 */
// 	private var _tempVerticesArray:Array<Float>;

// 	/**
// 	 * 矩形三角形
// 	 */
// 	private var _quadTriangles:Array<Int>;

// 	/**
// 	 * 颜色数组（未实现）
// 	 */
// 	private var _colors:Array<Int>;

// 	/**
// 	 * 是否正在播放
// 	 */
// 	private var _isPlay:Bool = true;

// 	/**
// 	 * 当前播放的动作名
// 	 */
// 	private var _actionName:String = "";

// 	/**
// 	 * 顶点缓存
// 	 */
// 	private var _trianglesVector:Map<AtlasRegion, Vector<Int>>;

// 	/**
// 	 * 精灵表垃圾池
// 	 */
// 	private var _spritePool:ObjectPool<Sprite>;

// 	/**
// 	 * 所有顶点数据
// 	 */
// 	private var allVerticesArray:Vector<Float> = new Vector<Float>();

// 	/**
// 	 * 所有三角形数据
// 	 */
// 	private var allTriangles:Vector<Int> = new Vector<Int>();

// 	/**
// 	 * 所有UV数据
// 	 */
// 	private var allUvs:Vector<Float> = new Vector<Float>();

// 	/**
// 	 * 顶点数据索引
// 	 */
// 	private var _buffdataPoint:Int = 0;

// 	/**
// 	 * 渲染的精灵对象
// 	 */
// 	private var _shape:Sprite;

// 	/**
// 	 * 是否为本地渲染，如果为true时，将支持透明度渲染，但渲染数会增加。
// 	 */
// 	public var isNative(get, set):Bool;

// 	private var _isNative:Bool = false;

// 	/**
// 	 * 是否使用缓存渲染，如果使用缓存渲染，如果使用换成渲染，则无法正常使用过渡动画
// 	 */
// 	public var isCache(get, set):Bool;

// 	private var _isCache:Bool = false;

// 	private function set_isCache(value:Bool):Bool {
// 		_isCache = value;
// 		if (_isCache && _cache == null) {
// 			_cache = [];
// 		}
// 		return value;
// 	}

// 	private function get_isCache():Bool {
// 		return _isCache;
// 	}

// 	/**
// 	 * 动画缓存映射
// 	 */
// 	private var _cache:Map<String, Dynamic>;

// 	private var _cacheBitmapData:BitmapData;

// 	private var _cacheId:String;

// 	private var _cached:Bool = false;

// 	private function set_isNative(value:Bool):Bool {
// 		_isNative = value;
// 		if (_isNative && _spritePool == null)
// 			_spritePool = new ObjectPool(() -> {
// 				return new Sprite();
// 			});
// 		return _isNative;
// 	}

// 	private function get_isNative():Bool {
// 		return _isNative;
// 	}

// 	/**
// 	 * 创建一个Spine对象
// 	 * @param skeletonData 骨骼数据
// 	 */
// 	public function new(skeletonData:SkeletonData) {
// 		super();

// 		skeleton = new Skeleton(skeletonData);
// 		skeleton.updateWorldTransform();

// 		_tempVerticesArray = new Array<Float>();
// 		_quadTriangles = new Array<Int>();
// 		_quadTriangles[0] = 0;
// 		_quadTriangles[1] = 1;
// 		_quadTriangles[2] = 2;
// 		_quadTriangles[3] = 2;
// 		_quadTriangles[4] = 3;
// 		_quadTriangles[5] = 0;
// 		_colors = new Array<Int>();

// 		#if !zygame
// 		this.addEventListener(Event.ADDED_TO_STAGE, onAddToStage);
// 		this.addEventListener(Event.REMOVED_FROM_STAGE, onRemoveToStage);
// 		#end

// 		_shape = new Sprite();
// 		this.addChild(_shape);

// 		_trianglesVector = new Map<AtlasRegion, Vector<Int>>();

// 		this.mouseChildren = false;
// 	}

// 	/**
// 	 * 统一的渲染入口
// 	 */
// 	public function onSpineUpdate(dt:Float):Void {
// 		if (batchs == null)
// 			advanceTime(dt);
// 	}

// 	#if zygame
// 	/**
// 	 * 当从舞台移除时
// 	 */
// 	override public function onRemoveToStage():Void {
// 		SpineManager.removeOnFrame(this);
// 	}

// 	override public function onAddToStage():Void {
// 		SpineManager.addOnFrame(this);
// 	}
// 	#else

// 	/**
// 	 * 当从舞台移除时
// 	 */
// 	public function onRemoveToStage(_):Void {
// 		SpineManager.removeOnFrame(this);
// 	}

// 	public function onAddToStage(_):Void {
// 		SpineManager.addOnFrame(this);
// 	}
// 	#end

// 	/**
// 	 * 丢弃
// 	 */
// 	#if zygame override #end public function destroy():Void {
// 		SpineManager.removeOnFrame(this);
// 		if (_spritePool != null)
// 			_spritePool.clear();
// 		_spritePool = null;
// 		removeChildren();
// 		graphics.clear();
// 	}

// 	/**
// 	 * 清空缓存
// 	 */
// 	public function clearCache():Void {
// 		_cache = [];
// 		_cached = false;
// 		skeleton.setTime(0);
// 	}

// 	/**
// 	 * 播放
// 	 */
// 	public function play(action:String = null, loop:Bool = true):Void {
// 		SpineManager.addOnFrame(this);
// 		_isPlay = true;
// 		if (action != null)
// 			_actionName = action;
// 		if (isCache) {
// 			clearCache();
// 		}
// 	}

// 	/**
// 	 * 是否正在播放
// 	 */
// 	public var isPlay(get, set):Bool;

// 	private function get_isPlay():Bool {
// 		if (_isPlay)
// 			return true;
// 		if (actionName == "" || actionName == null)
// 			return false;
// 		return true;
// 	}

// 	private function set_isPlay(bool:Bool):Bool {
// 		_isPlay = bool;
// 		return bool;
// 	}

// 	/**
// 	 * 获取当前播放的动作
// 	 */
// 	public var actionName(get, never):String;

// 	private function get_actionName():String {
// 		return _actionName;
// 	}

// 	/**
// 	 * 停止
// 	 */
// 	public function stop():Void {
// 		SpineManager.removeOnFrame(this);
// 		_isPlay = false;
// 	}

// 	/**
// 	 * 激活渲染
// 	 * @param delta
// 	 */
// 	public function advanceTime(delta:Float):Void {
// 		if (_isPlay == false)
// 			return;
// 		if (isNative)
// 			renderNative();
// 		else {
// 			if (isCache) {
// 				_cacheId = Std.string(Math.round(skeleton.time / .01) * .01);
// 				if (_cache.exists(_cacheId)) {
// 					renderCacheTriangles(_cache.get(_cacheId));
// 					return;
// 				} else if (_cached)
// 					return;
// 			}
// 			renderTriangles();
// 		}
// 	}

// 	/**
// 	 * 渲染缓存三角形，使用isCache=true时可正常使用
// 	 */
// 	private function renderCacheTriangles(data:Dynamic):Void {
// 		_shape.graphics.clear();
// 		_shape.graphics.beginBitmapFill(_cacheBitmapData, null, false, false);
// 		_shape.graphics.drawTriangles(data.va, data.t, data.uv, TriangleCulling.NONE);
// 		_shape.graphics.endFill();
// 	}

// 	private function renderNative():Void {
// 		_buffdataPoint = 0;
// 		var drawOrder:Array<Slot> = skeleton.drawOrder;
// 		var n:Int = drawOrder.length;
// 		var triangles:Array<Int> = null;
// 		var uvs:Array<Float> = null;
// 		var verticesLength:Int = 0;
// 		var atlasRegion:AtlasRegion;
// 		var slot:Slot;
// 		// var r:Float = 0, g:Float = 0, b:Float = 0, a:Float = 0;

// 		var max:Int = _shape.numChildren - 1;
// 		while (max >= 0) {
// 			var spr:Sprite = cast _shape.getChildAt(max);
// 			_shape.removeChild(spr);
// 			_spritePool.remove(spr);
// 			_spritePool.add(spr);
// 			max--;
// 		}
// 		allTriangles.splice(0, allTriangles.length);

// 		var t:Int = 0;

// 		for (i in 0...n) {
// 			// 获取骨骼
// 			slot = drawOrder[i];
// 			// 初始化参数
// 			triangles = null;
// 			uvs = null;
// 			atlasRegion = null;
// 			// 如果骨骼的渲染物件存在
// 			if (slot.attachment != null) {
// 				if (Std.isOfType(slot.attachment, RegionAttachment)) {
// 					// 如果是矩形
// 					var region:RegionAttachment = cast slot.attachment;
// 					verticesLength = 8;
// 					region.computeWorldVertices(slot.bone, _tempVerticesArray, 0, 2);
// 					uvs = region.getUVs();
// 					triangles = _quadTriangles;
// 					atlasRegion = cast region.getRegion();
// 				} else if (Std.isOfType(slot.attachment, MeshAttachment)) {
// 					// 如果是网格
// 					var region:MeshAttachment = cast slot.attachment;
// 					verticesLength = 8;
// 					region.computeWorldVertices(slot, 0, region.getWorldVerticesLength(), _tempVerticesArray, 0, 2);
// 					uvs = region.getUVs();
// 					triangles = region.getTriangles();
// 					atlasRegion = cast region.getRegion();
// 				}

// 				// 矩形绘制
// 				if (atlasRegion != null) {
// 					var spr:Sprite = _spritePool.get();
// 					var curBitmap:BitmapData = cast atlasRegion.page.rendererObject;
// 					spr.graphics.clear();
// 					spr.graphics.beginBitmapFill(curBitmap, null, true, true);
// 					spr.graphics.drawTriangles(ofArrayFloat(_tempVerticesArray), ofArrayInt(triangles), ofArrayFloat(uvs), TriangleCulling.NONE);
// 					spr.graphics.endFill();
// 					spr.alpha = slot.color.a;
// 					// Color change
// 					spr.transform.colorTransform.redMultiplier = slot.color.r;
// 					spr.transform.colorTransform.greenMultiplier = slot.color.g;
// 					spr.transform.colorTransform.blueMultiplier = slot.color.b;
// 					switch (slot.data.blendMode) {
// 						case BlendMode.additive:
// 							spr.blendMode = openfl.display.BlendMode.ADD;
// 						case BlendMode.multiply:
// 							spr.blendMode = openfl.display.BlendMode.MULTIPLY;
// 						case BlendMode.screen:
// 							spr.blendMode = openfl.display.BlendMode.SCREEN;
// 						case BlendMode.normal:
// 							spr.blendMode = openfl.display.BlendMode.NORMAL;
// 					}
// 					_shape.addChild(spr);
// 				}
// 			}
// 		}
// 	}

// 	/**
// 	 * 渲染实现
// 	 */
// 	private function renderTriangles():Void {
// 		var clipper:SkeletonClipping = SkeletonSprite.clipper;
// 		_buffdataPoint = 0;
// 		var uindex:Int = 0;
// 		var drawOrder:Array<Slot> = skeleton.drawOrder;
// 		var n:Int = drawOrder.length;
// 		var triangles:Array<Int> = null;
// 		var uvs:Array<Float> = null;
// 		var verticesLength:Int = 0;
// 		var atlasRegion:AtlasRegion;
// 		var slot:Slot;
// 		// var r:Float = 0, g:Float = 0, b:Float = 0, a:Float = 0;
// 		var bitmapData:BitmapData = null;

// 		var v:Vector<Int> = null;

// 		_shape.graphics.clear();
// 		allTriangles.splice(0, allTriangles.length);

// 		var t:Int = 0;

// 		for (i in 0...n) {
// 			// 获取骨骼
// 			slot = drawOrder[i];
// 			// 初始化参数
// 			triangles = null;
// 			uvs = null;
// 			atlasRegion = null;
// 			// 如果骨骼的渲染物件存在
// 			if (slot.attachment != null) {
// 				// 如果不可见的情况下，则隐藏
// 				if (slot.color.a == 0)
// 					continue;
// 				if (Std.isOfType(slot.attachment, ClippingAttachment)) {
// 					// 如果是剪切
// 					// var region:ClippingAttachment = cast slot.attachment;
// 					// clipper.clipStart(slot, region);
// 					continue;
// 				} else if (Std.isOfType(slot.attachment, RegionAttachment)) {
// 					// 如果是矩形
// 					var region:RegionAttachment = cast slot.attachment;
// 					verticesLength = 8;
// 					region.computeWorldVertices(slot.bone, _tempVerticesArray, 0, 2);
// 					uvs = region.getUVs();
// 					triangles = _quadTriangles;
// 					atlasRegion = cast region.getRegion();
// 				} else if (Std.isOfType(slot.attachment, MeshAttachment)) {
// 					// 如果是网格
// 					var region:MeshAttachment = cast slot.attachment;
// 					verticesLength = 8;
// 					region.computeWorldVertices(slot, 0, region.getWorldVerticesLength(), _tempVerticesArray, 0, 2);
// 					uvs = region.getUVs();
// 					triangles = region.getTriangles();
// 					atlasRegion = cast region.getRegion();
// 				}

// 				// if (clipper.isClipping()) {
// 				// 	clipper.clipTriangles(_tempVerticesArray,_tempVerticesArray.length,triangles,triangles.length,uvs,1,1,false);
// 				// 	_tempVerticesArray = clipper.getClippedVertices();
// 				// 	triangles = clipper.getClippedTriangles();
// 				// }

// 				// 矩形绘制
// 				if (atlasRegion != null) {
// 					if (batchs != null) {
// 						// 上传到批量渲染
// 						batchs.uploadBuffData(this, ofArrayFloat(_tempVerticesArray), ofArrayInt(triangles), ofArrayFloat(uvs));
// 					} else {
// 						if (bitmapData != atlasRegion.page.rendererObject) {
// 							bitmapData = cast atlasRegion.page.rendererObject;
// 						}
// 						// 顶点重新计算
// 						// v = ofArrayInt(triangles);
// 						for (vi in 0...triangles.length) {
// 							// 追加顶点
// 							allTriangles[_buffdataPoint] = triangles[vi] + t;
// 							_buffdataPoint++;
// 						}

// 						for (ui in 0...uvs.length) {
// 							// 追加坐标
// 							allVerticesArray[uindex] = _tempVerticesArray[ui];
// 							// 追加UV
// 							allUvs[uindex] = uvs[ui];
// 							uindex++;
// 						}
// 						t += Std.int(uvs.length / 2);
// 					}
// 				}

// 				// clipper.clipEndWithSlot(slot);
// 			}
// 		}

// 		if (batchs == null && allTriangles.length > 2) {
// 			_shape.graphics.clear();
// 			_shape.graphics.beginBitmapFill(bitmapData, null, false, false);
// 			_shape.graphics.drawTriangles(allVerticesArray, allTriangles, allUvs, TriangleCulling.NONE);
// 			_shape.graphics.endFill();
// 			// 缓存
// 			if (isCache && _cache != null) {
// 				if (_cacheBitmapData == null)
// 					_cacheBitmapData = bitmapData;
// 				_cache[_cacheId] = {
// 					va: allVerticesArray.concat(),
// 					t: allTriangles.concat(),
// 					uv: allUvs.concat()
// 				};
// 			}
// 		}
// 	}

// 	/**
// 	 * 渲染数组转换
// 	 * @param data
// 	 * @return Vector<Int>
// 	 */
// 	private function ofArrayInt(data:Array<Int>):Vector<Int> {
// 		var v:Vector<Int> = new Vector<Int>();
// 		for (i in 0...data.length)
// 			v.set(i, data[i]);
// 		return v;
// 	}

// 	/**
// 	 * 渲染数组转换
// 	 * @param data
// 	 * @return Vector<Float>
// 	 */
// 	private function ofArrayFloat(data:Array<Float>):Vector<Float> {
// 		var v:Vector<Float> = new Vector<Float>();
// 		for (i in 0...data.length)
// 			v.set(i, data[i]);
// 		return v;
// 	}

// 	#if !flash
// 	/**
// 	 * 重构触摸事件，无法触发触摸的问题
// 	 * @param x
// 	 * @param y
// 	 * @param shapeFlag
// 	 * @param stack
// 	 * @param interactiveOnly
// 	 * @param hitObject
// 	 * @return Bool
// 	 */
// 	override private function __hitTest(x:Float, y:Float, shapeFlag:Bool, stack:Array<DisplayObject>, interactiveOnly:Bool, hitObject:DisplayObject):Bool {
// 		// var bool:Bool = super.__hitTest(x, y, shapeFlag, stack, interactiveOnly, hitObject);
// 		// if (bool == true) {
// 		// return true;
// 		// }
// 		if (this.mouseEnabled == false || this.visible == false)
// 			return false;
// 		if (this.getBounds(stage).contains(x, y)) {
// 			if (stack != null)
// 				stack.push(this);
// 			return true;
// 		}
// 		return false;
// 	}
// 	#end

// 	public function getMaxTime():Float {
// 		return 0;
// 	}
// }
