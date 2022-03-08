package spine.openfl;

import spine.events.SpineEvent;
import spine.events.AnimationEvent;
import spine.SkeletonData;
import spine.AnimationState;
import spine.AnimationStateData;

#if test
@:build(zygame.macro.performance.PerformanceUtils.build())
#end
class SkeletonGPUAnimation extends SkeletonGPUSprite {
	public var state:AnimationState;

	/**
	 * 当前动画数据
	 */
	private var _currentAnimation:Animation;

	public var timeScale:Float = 1;

	public var actionName:String = null;

	public function new(skeletonData:SkeletonData, stateData:AnimationStateData = null) {
		super(skeletonData);
		#if (spine_hx <= "3.6.0")
		skeleton.setFlipY(true);
		#else
		skeleton.setScaleY(-1);
		#end
		state = new AnimationState(stateData == null ? new AnimationStateData(skeletonData) : stateData);
		_advanceTime(0);
		setSkeletonData(skeletonData);
	}

	/**
	 * 设置新的骨架数据，实现骨骼换肤可使用这个。
	 * @param skeletonData 
	 */
	public function setSkeletonData(skeletonData:SkeletonData):Void {
		if (skeleton.getData() == skeletonData)
			return;
		skeleton = new Skeleton(skeletonData);
		#if (spine_hx <= "3.6.0")
		skeleton.setFlipY(true);
		#else
		skeleton.setScaleY(-1);
		#end
		state.getData().skeletonData = skeletonData;
		skeleton.updateWorldTransform();
	}

	override public function advanceTime(time:Float):Void {
		if (!this.visible || !isPlay)
			return;
		_advanceTime(time);
	}

	private function _advanceTime(time:Float):Void {
		state.update(time / timeScale);
		state.apply(skeleton);
		// skeleton.update(time / timeScale);
		skeleton.updateWorldTransform();
	}

	/**
	 * 播放动画
	 * @param action 动作名
	 * @param loop 是否循环
	 */
	public function play(action:String = null, loop:Bool = true):Void {
		isPlay = true;
		if (action != this.actionName) {
			if (action != null && action != "") {
				this.state.setAnimationByName(0, action, loop);
			}
			this._currentAnimation = getAnimation(action);
		}
	}

	public function getAnimation(name:String):Animation {
		for (animation in this.state.getData().getSkeletonData().animations) {
			if (animation.name == name)
				return animation;
		}
		return null;
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
		_advanceTime(0);
	}

	/**
	 * 获取最大持续时间
	 * @return Float
	 */
	override function getMaxTime():Float {
		if (_currentAnimation != null)
			return _currentAnimation.getDuration();
		return super.getMaxTime();
	}

	private var _event:AnimationEvent;

	override function addEventListener<T>(type:openfl.events.EventType<T>, listener:T->Void, useCapture:Bool = false, priority:Int = 0,
			useWeakReference:Bool = false) {
		if (_event == null && state != null) {
			_event = new AnimationEvent();
			this.state.addListener(_event);
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
