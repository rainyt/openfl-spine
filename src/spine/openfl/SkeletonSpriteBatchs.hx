package spine.openfl;

#if zygame
import zygame.components.ZBox;
#end
import spine.attachments.MeshAttachment;
import spine.attachments.RegionAttachment;
import spine.support.graphics.TextureAtlas.AtlasRegion;
import spine.base.SpineBaseDisplay;
import openfl.display.Sprite;
import openfl.Vector;
import openfl.display.DisplayObject;
import spine.openfl.SkeletonSprite;
import openfl.events.Event;
import openfl.display.TriangleCulling;
import openfl.display.BitmapData;
import spine.utils.VectorUtils;
import zygame.utils.SpineManager;
import spine.shader.SpineRenderBatchShader;
import spine.shader.SpineRenderShader;
import openfl.display3D.Context3DTextureFilter;

/**
 * 骨骼批渲染处理
 */
@:noCompletion
class SkeletonSpriteBatchs extends #if zygame ZBox #else Sprite #end implements SpineBaseDisplay {
	/**
	 * 着色器
	 */
	private var _shader:SpineRenderBatchShader;

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

	private var allXy:Array<Float> = [];

	private var allScale:Array<Float> = [];

	/**
	 * 所有UV数据
	 */
	private var allUvs:Vector<Float> = new Vector<Float>();

	private var _bitmapData:BitmapData;
	private var _setXBool:Bool = true;
	private var _isClearTriangles:Bool = true;

	/**
	 * 是否为独立运行，不受SpineManager的影响
	 */
	public var independent:Bool = false;

	public function new() {
		super();
		// _bitmapData = bitmapData;
		#if zygame
		SpineManager.addOnFrame(this, true);
		#else
		SpineManager.addOnFrame(this);
		#end
		_shader = new SpineRenderBatchShader();
	}

	/**
	 * 是否正在播放
	 */
	public var isPlay(get, set):Bool;

	private function get_isPlay():Bool {
		return true;
	}

	private function set_isPlay(bool:Bool):Bool {
		return bool;
	}

	public function onSpineUpdate(dt:Float):Void {
		endFill();
	}

	public function clearTriangles():Void {
		allTriangles.splice(0, allTriangles.length);
	}

	private var _uploadBuffDataMaps:Map<SkeletonSprite, {
		v:Vector<Float>,
		i:Vector<Int>,
		uvs:Vector<Float>,
		color:Array<Float>,
		blend:Array<Float>,
		alphas:Array<Float>
	}> = [];

	/**
	 * 上传数据渲染
	 * @param v 
	 * @param i 
	 * @param m 
	 */
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
			// allXy.push(0);
			// allXy.push(0);
			allScale.push(sprite.scaleX);
			allScale.push(sprite.scaleY);
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

	/**
	 * 最终批渲染
	 */
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
		_shader.data.u_size.value = [this.stage.stageWidth, this.stage.stageHeight];
		#end
		_shader.data.bitmap.filter = false ? LINEAR : NEAREST;
		_shader.a_texalpha.value = allTrianglesAlpha;
		_shader.a_texblendmode.value = allTrianglesBlendMode;
		_shader.a_texcolor.value = allTrianglesColor;
		_shader.a_xy.value = allXy;
		_shader.a_scale.value = allScale;
		this.graphics.clear();
		this.graphics.beginShaderFill(_shader);
		this.graphics.drawTriangles(allVerticesArray, allTriangles, allUvs, TriangleCulling.NONE);
		this.graphics.endFill();
		_isClearTriangles = false;
	}

	/**
	 * 方法重写
	 * @param child 
	 * @param index 
	 * @return DisplayObject
	 */
	override public function addChildAt(child:DisplayObject, index:Int):DisplayObject {
		if (!Std.isOfType(child, SkeletonSprite)) {
			throw "请不要添加非spine.openfl.SkeletonSprite对象！";
		}
		var s:SkeletonSprite = cast(child, SkeletonSprite);
		s.batchs = this;
		s.graphics.clear();
		return super.addChildAt(child, index);
	}

	public function isHidden():Bool {
		return this.alpha == 0 || !this.visible;
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
}
