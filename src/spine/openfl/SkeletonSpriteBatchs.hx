package spine.openfl;

#if !spine4_2
#if api_lang_en
/**
 * Skeleton batch rendering handler
 * Batches multiple SkeletonSprite objects for efficient rendering
 */
#else
/**
 * 骨骼批渲染处理
 * 批量处理多个SkeletonSprite对象以提高渲染效率
 */
#end
#if zygame
import zygame.components.ZBox;
#else
import openfl.display.Sprite;
#end
import spine.attachments.MeshAttachment;
import spine.attachments.RegionAttachment;
import spine.support.graphics.TextureAtlas.AtlasRegion;
import spine.base.SpineBaseDisplay;
import openfl.Vector;
import openfl.display.DisplayObject;
import spine.openfl.SkeletonSprite;
import openfl.display.TriangleCulling;
import openfl.display.BitmapData;
import zygame.utils.SpineManager;
import spine.shader.SpineRenderBatchShader;
import openfl.display3D.Context3DTextureFilter;

@:noCompletion
class SkeletonSpriteBatchs extends #if zygame ZBox #else Sprite #end implements SpineBaseDisplay {
	#if api_lang_en
	/**
	 * Shader for batch rendering
	 */
	#else
	/**
	 * 着色器
	 */
	#end
	private var _shader:SpineRenderBatchShader;

	#if api_lang_en
	/**
	 * Last draw time
	 */
	#else
	/**
	 * 最后绘制时间
	 */
	#end
	public var lastDrawTime:Float = 0;

	#if api_lang_en
	/**
	 * All vertices data
	 */
	#else
	/**
	 * 所有顶点数据
	 */
	#end
	private var allVerticesArray:Vector<Float> = new Vector<Float>(0, false);

	#if api_lang_en
	/**
	 * All triangles data
	 */
	#else
	/**
	 * 所有三角形数据
	 */
	#end
	private var allTriangles:Vector<Int> = new Vector<Int>(0, false);

	#if api_lang_en
	/**
	 * All triangles alpha properties
	 */
	#else
	/**
	 * 所有顶点透明属性
	 */
	#end
	private var allTrianglesAlpha:Array<Float> = [];

	#if api_lang_en
	/**
	 * All triangles blend mode properties
	 */
	#else
	/**
	 * 所有顶点BlendMode属性
	 */
	#end
	private var allTrianglesBlendMode:Array<Float> = [];

	#if api_lang_en
	/**
	 * All triangles color multiplication
	 */
	#else
	/**
	 * 所有顶点的颜色相乘
	 */
	#end
	private var allTrianglesColor:Array<Float> = [];

	#if api_lang_en
	/**
	 * All position data
	 */
	#else
	/**
	 * 所有位置数据
	 */
	#end
	private var allXy:Array<Float> = [];

	#if api_lang_en
	/**
	 * All scale and rotation data
	 */
	#else
	/**
	 * 所有缩放和旋转数据
	 */
	#end
	private var allScale:Array<Float> = [];

	#if api_lang_en
	/**
	 * All UV data
	 */
	#else
	/**
	 * 所有UV数据
	 */
	#end
	private var allUvs:Vector<Float> = new Vector<Float>(0, false);

	#if api_lang_en
	/**
	 * Bitmap data for rendering
	 */
	#else
	/**
	 * 渲染用的位图数据
	 */
	#end
	private var _bitmapData:BitmapData;
	private var _setXBool:Bool = true;
	private var _isClearTriangles:Bool = true;

	#if api_lang_en
	/**
	 * Whether to run independently, not affected by SpineManager
	 */
	#else
	/**
	 * 是否为独立运行，不受SpineManager的影响
	 */
	#end
	public var independent:Bool = false;

	#if api_lang_en
	/**
	 * Creates a new SkeletonSpriteBatchs
	 */
	#else
	/**
	 * 创建一个新的SkeletonSpriteBatchs
	 */
	#end
	public function new() {
		super();
		#if zygame
		SpineManager.addOnFrame(this, true);
		#else
		SpineManager.addOnFrame(this);
		#end
		_shader = new SpineRenderBatchShader();
	}

	#if api_lang_en
	/**
	 * Whether animation is playing
	 */
	#else
	/**
	 * 是否正在播放
	 */
	#end
	public var isPlay(get, set):Bool;

	#if api_lang_en
	/**
	 * Gets whether animation is playing
	 * @return Always returns true
	 */
	#else
	/**
	 * 获取是否正在播放
	 * @return 始终返回true
	 */
	#end
	private function get_isPlay():Bool {
		return true;
	}

	#if api_lang_en
	/**
	 * Sets whether animation is playing
	 * @param bool Boolean value
	 * @return The input boolean value
	 */
	#else
	/**
	 * 设置是否正在播放
	 * @param bool 布尔值
	 * @return 输入的布尔值
	 */
	#end
	private function set_isPlay(bool:Bool):Bool {
		return bool;
	}

	#if api_lang_en
	/**
	 * Updates the batch rendering
	 * @param dt Delta time
	 */
	#else
	/**
	 * 更新批渲染
	 * @param dt 时间增量
	 */
	#end
	public function onSpineUpdate(dt:Float):Void {
		endFill();
	}

	#if api_lang_en
	/**
	 * Clears the triangles data
	 */
	#else
	/**
	 * 清除三角形数据
	 */
	#end
	public function clearTriangles():Void {
		allTriangles.splice(0, allTriangles.length);
	}

	#if api_lang_en
	/**
	 * Map of uploaded buffer data for each SkeletonSprite
	 */
	#else
	/**
	 * 每个SkeletonSprite的上传缓冲区数据映射
	 */
	#end
	private var _uploadBuffDataMaps:Map<SkeletonSprite, {
		v:Vector<Float>,
		i:Vector<Int>,
		uvs:Vector<Float>,
		color:Array<Float>,
		blend:Array<Float>,
		alphas:Array<Float>
	}> = [];

	#if api_lang_en
	/**
	 * Uploads buffer data for rendering
	 * @param sprite SkeletonSprite to upload data for
	 * @param v Vertices data
	 * @param i Triangles indices
	 * @param uvs UV data
	 * @param color Color data
	 * @param blend Blend mode data
	 * @param alphas Alpha data
	 */
	#else
	/**
	 * 上传数据渲染
	 * @param sprite 要上传数据的SkeletonSprite
	 * @param v 顶点数据
	 * @param i 三角形索引
	 * @param uvs UV数据
	 * @param color 颜色数据
	 * @param blend 混合模式数据
	 * @param alphas 透明度数据
	 */
	#end
	public function uploadBuffData(sprite:SkeletonSprite, v:Vector<Float>, i:Vector<Int>, uvs:Vector<Float>, color:Array<Float>, blend:Array<Float>,
			alphas:Array<Float>):Void {
		if (sprite.visible == false) {
			return;
		}
		if (_bitmapData == null) {
			for (slot in sprite.skeleton.drawOrder) {
				var region:AtlasRegion = null;
				if (Std.isOfType(slot.attachment, RegionAttachment)) {
					region = cast cast(slot.attachment, RegionAttachment).getRegion();
				} else if (Std.isOfType(slot.attachment, MeshAttachment)) {
					region = cast cast(slot.attachment, MeshAttachment).getRegion();
				}
				if (region != null)
					_bitmapData = region.page.rendererObject;
				if (_bitmapData != null)
					break;
			}
		}
		_uploadBuffDataMaps.set(sprite, {
			v: v.copy(),
			i: i.copy(),
			uvs: uvs.copy(),
			color: color.copy(),
			blend: blend.copy(),
			alphas: alphas.copy()
		});
	}

	#if api_lang_en
	/**
	 * Flushes the buffer data for a SkeletonSprite
	 * @param sprite SkeletonSprite to flush data for
	 */
	#else
	/**
	 * 刷新SkeletonSprite的缓冲区数据
	 * @param sprite 要刷新数据的SkeletonSprite
	 */
	#end
	public function flushBuffData(sprite:SkeletonSprite):Void {
		var buffer = _uploadBuffDataMaps.get(sprite);
		if (buffer == null)
			return;
		// 更新顶点
		var t:Int = Std.int(allUvs.length / 2);
		for (vi in buffer.i) {
			allTriangles.push(vi + t);
			allXy.push(sprite.x);
			allXy.push(sprite.y);
			allScale.push(sprite.scaleX);
			allScale.push(sprite.scaleY);
			allScale.push(sprite.rotation);
		}
		for (uv in buffer.uvs) {
			allUvs.push(uv);
		}
		for (c in buffer.color) {
			allTrianglesColor.push(c);
		}
		for (b in buffer.blend) {
			allTrianglesBlendMode.push(b);
		}
		for (a in buffer.alphas) {
			allTrianglesAlpha.push(a);
		}
		for (xy in buffer.v) {
			allVerticesArray.push(xy);
		}
	}

	#if api_lang_en
	/**
	 * Final batch rendering
	 */
	#else
	/**
	 * 最终批渲染
	 */
	#end
	private function endFill():Void {
		allVerticesArray.splice(0, allVerticesArray.length);
		allUvs.splice(0, allUvs.length);
		allTriangles.splice(0, allTriangles.length);
		allTrianglesAlpha.splice(0, allTrianglesAlpha.length);
		allTrianglesColor.splice(0, allTrianglesColor.length);
		allTrianglesBlendMode.splice(0, allTrianglesBlendMode.length);
		allScale.splice(0, allScale.length);
		allXy.splice(0, allXy.length);

		for (i in 0...this.numChildren) {
			var display:SkeletonSprite = cast this.getChildAt(i);
			flushBuffData(display);
		}
		if (allTriangles.length == 0) {
			this.graphics.clear();
			return;
		}
		_shader.data.bitmap.input = _bitmapData;
		// Smoothing smoothing todo
		#if zygame
		if (Std.isOfType(this.parent, zygame.components.ZSpine)) {
			_shader.data.u_malpha.value = [this.parent.alpha * this.alpha];
		} else {
			_shader.data.u_malpha.value = [this.alpha];
		}
		#else
		_shader.data.u_malpha.value = [this.alpha];
		#end
		#if zygame
		_shader.data.u_size.value = [this.getStageWidth(), this.getStageHeight()];
		#else
		_shader.data.u_size.value = [
			this.stage.stageWidth * @:privateAccess this.__worldTransform.a,
			this.stage.stageHeight * @:privateAccess this.__worldTransform.d
		];
		#end
		_shader.data.bitmap.filter = false ? LINEAR : NEAREST;
		_shader.a_texalpha.value = allTrianglesAlpha;
		_shader.a_texblendmode.value = allTrianglesBlendMode;
		_shader.a_texcolor.value = allTrianglesColor;
		_shader.a_xy.value = allXy;
		_shader.a_scaleAndRotation.value = allScale;
		this.graphics.clear();
		this.graphics.beginShaderFill(_shader);
		this.graphics.drawTriangles(allVerticesArray, allTriangles, allUvs, TriangleCulling.NONE);
		this.graphics.endFill();
		_isClearTriangles = false;
	}

	#if api_lang_en
	/**
	 * Overrides addChildAt method
	 * @param child Child display object to add
	 * @param index Index to add child at
	 * @return Added display object
	 */
	#else
	/**
	 * 方法重写
	 * @param child 要添加的子显示对象
	 * @param index 添加子对象的索引
	 * @return 添加的显示对象
	 */
	#end
	override public function addChildAt(child:DisplayObject, index:Int):DisplayObject {
		if (!Std.isOfType(child, SkeletonSprite)) {
			throw "请不要添加非spine.openfl.SkeletonSprite对象！";
		}
		var s:SkeletonSprite = cast(child, SkeletonSprite);
		s.batchs = this;
		s.graphics.clear();
		return super.addChildAt(child, index);
	}

	#if api_lang_en
	/**
	 * Checks if the batch is hidden
	 * @return Whether the batch is hidden
	 */
	#else
	/**
	 * 检查批处理是否隐藏
	 * @return 批处理是否隐藏
	 */
	#end
	public function isHidden():Bool {
		return this.alpha == 0 || !this.visible;
	}

	#if !flash
	#if api_lang_en
	/**
	 * Overrides hit test method to fix touch issues
	 * @param x X coordinate
	 * @param y Y coordinate
	 * @param shapeFlag Shape flag
	 * @param stack Display object stack
	 * @param interactiveOnly Interactive only flag
	 * @param hitObject Hit object
	 * @return Whether the point hits the object
	 */
	#else
	/**
	 * 重构触摸事件，无法触发触摸的问题
	 * @param x X坐标
	 * @param y Y坐标
	 * @param shapeFlag 形状标志
	 * @param stack 显示对象栈
	 * @param interactiveOnly 仅交互标志
	 * @param hitObject 命中对象
	 * @return 点是否命中对象
	 */
	#end
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
}
#end
