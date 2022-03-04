package spine.openfl;

import zygame.utils.SpineManager;
import openfl.Vector;
import openfl.display.BitmapData;
import spine.attachments.RegionAttachment;
import spine.openfl.gpu.SoltData;
import openfl.display.Sprite;

/**
 * Bate：该功能为实验性功能，未完成
 * 使用GPU渲染骨骼动画，当前模式下，不能使用BlendMode.ADD等渲染模式
 */
class SkeletonGPUSprite extends Sprite implements spine.base.SpineBaseDisplay {
	/**
	 * 骨架对象
	 */
	public var skeleton:Skeleton;

	/**
	 * 是否正在播放
	 */
	public var isPlay(get, set):Bool;

	private var _isPlay:Bool = false;

	/**
	 * 渲染帧率是否独立
	 */
	public var independent:Bool;

	/**
	 * 骨骼数据绑定
	 */
	private var _soltDataMaps:Map<Slot, SoltData> = [];

	public function new(skeletonData:SkeletonData) {
		super();
		// 初始化骨架
		skeleton = new Skeleton(skeletonData);
		#if (spine_hx <= "3.6.0")
		skeleton.setFlipY(true);
		#else
		skeleton.setScaleY(-1);
		#end
		skeleton.updateWorldTransform();
		this.initSkeletonData();
		#if !zygame
		this.addEventListener(openfl.events.Event.ADDED_TO_STAGE, onAddToStage);
		this.addEventListener(openfl.events.Event.REMOVED_FROM_STAGE, onRemoveToStage);
		#end
	}

	/**
	 * 开始初始化骨骼的顶点数据
	 */
	private function initSkeletonData():Void {
		for (slot in skeleton.drawOrder) {
			trace(slot.attachment);
			var soltData = new SoltData(slot);
			_soltDataMaps.set(slot, soltData);
		}
		onSpineUpdate(0);
	}

	private function get_isPlay():Bool {
		if (_isPlay)
			return true;
		return false;
	}

	private function set_isPlay(bool:Bool):Bool {
		_isPlay = bool;
		return bool;
	}

	private var _isHidden:Bool = false;

	public function isHidden():Bool {
		_isHidden = this.__worldAlpha == 0 || !this.__visible;
		return _isHidden;
	}

	public function onSpineUpdate(dt:Float) {
		advanceTime(dt);
		renderGPUAnimate();
	}

	public function advanceTime(dt:Float) {}

	private function renderGPUAnimate():Void {
		// todo 这里应该需要处理一下drawOrder循序是否发生变化，如果没有变化，这4个变量都不需要发生变化
		var allvertices:Vector<Float> = new Vector();
		var alluvs:Vector<Float> = new Vector();
		var alltriangles:Vector<Int> = new Vector();
		var drawBitmapData:BitmapData = null;
		var t = 0;
		for (slot in skeleton.drawOrder) {
			var boneData = _soltDataMaps.get(slot);
			if (boneData != null && boneData.vertices != null) {
				for (f in boneData.vertices) {
					allvertices.push(f);
				}
				for (f in boneData.uvs) {
					alluvs.push(f);
				}
				for (i in boneData.triangles) {
					alltriangles.push(t + i);
				}
				if (drawBitmapData == null && boneData.bitmapData != null) {
					drawBitmapData = boneData.bitmapData;
				}
				t += Std.int(boneData.uvs.length / 2);
				trace(slot.bone.getY());
			}
		}
		// 渲染
		this.graphics.beginBitmapFill(drawBitmapData);
		this.graphics.drawTriangles(allvertices, alltriangles, alluvs);
		this.graphics.endFill();
	}

	public function getMaxTime():Float {
		return 0;
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
}
