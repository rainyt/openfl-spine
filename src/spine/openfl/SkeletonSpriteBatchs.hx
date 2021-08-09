package spine.openfl;

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

/**
 * 骨骼批渲染处理
 */
@:noCompletion
class SkeletonSpriteBatchs extends Sprite implements SpineBaseDisplay {
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
		SpineManager.addOnFrame(this);
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
		this.graphics.clear();
		endFill();
		allVerticesArray.splice(0, allVerticesArray.length);
		allUvs.splice(0, allUvs.length);
		allTriangles.splice(0, allTriangles.length);
		allTrianglesAlpha.splice(0, allTrianglesAlpha.length);
		allTrianglesColor.splice(0, allTrianglesColor.length);
		allTrianglesBlendMode.splice(0, allTrianglesBlendMode.length);
	}

	public function clearTriangles():Void {
		allTriangles.splice(0, allTriangles.length);
	}

	/**
	 * 上传数据渲染
	 * @param v 
	 * @param i 
	 * @param m 
	 */
	public function uploadBuffData(sprite:SkeletonSprite, v:Vector<Float>, i:Vector<Int>, uvs:Vector<Float>, color:Array<Float>, blend:Array<Float>,
			alphas:Array<Float>):Void {
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
		// 更新顶点
		var t:Int = Std.int(allUvs.length / 2);
		for (vi in i) {
			allTriangles.push(vi + t);
		}
		for (uv in uvs) {
			allUvs.push(uv);
		}
		for (c in color) {
			allTrianglesColor.push(c);
		}
		for (b in blend) {
			allTrianglesBlendMode.push(b);
		}
		for (a in alphas) {
			allTrianglesAlpha.push(a);
		}
		// 更新坐标
		var isX = true;
		for (xy in v) {
			if (isX) {
				allVerticesArray.push(xy + sprite.x);
			} else {
				allVerticesArray.push(xy + sprite.y);
			}
			isX = !isX;
		}
	}

	/**
	 * 最终批渲染
	 */
	private function endFill():Void {
		this.graphics.beginBitmapFill(_bitmapData, null, true, true);
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
