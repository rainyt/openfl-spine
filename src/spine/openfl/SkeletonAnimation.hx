/******************************************************************************
 * Spine Runtimes Software License
 * Version 2.1
 * 
 * Copyright (c) 2013, Esoteric Software
 * All rights reserved.
 * 
 * You are granted a perpetual, non-exclusive, non-sublicensable and
 * non-transferable license to install, execute and perform the Spine Runtimes
 * Software (the "Software") solely for internal use. Without the written
 * permission of Esoteric Software (typically granted by licensing Spine), you
 * may not (a) modify, translate, adapt or otherwise create derivative works,
 * improvements of the Software or develop new applications using the Software
 * or (b) remove, delete, alter or obscure any trademarks or any copyright,
 * trademark, patent or other intellectual property or proprietary rights
 * notices on or in the Software, including any copy thereof. Redistributions
 * in binary or source form must include this license and terms.
 * 
 * THIS SOFTWARE IS PROVIDED BY ESOTERIC SOFTWARE "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 * EVENT SHALL ESOTERIC SOFTARE BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*****************************************************************************/

package spine.openfl;

import spine.events.SpineEvent;
import spine.events.AnimationEvent;
import spine.SkeletonData;
import spine.AnimationState;
import spine.AnimationStateData;

class SkeletonAnimation extends SkeletonSprite {
	public var state:AnimationState;

	/**
	 * 当前动画数据
	 */
	private var _currentAnimation:Animation;

	/**
	 * 构造一个SkeletonAnimation
	 * @param skeletonData 
	 * @param stateData 
	 */
	public function new(skeletonData:SkeletonData, stateData:AnimationState = null) {
		super(skeletonData);
		#if (spine_hx <= "3.6.0")
		skeleton.setFlipY(true);
		#else
		skeleton.setScaleY(-1);
		#end
		state = stateData != null ? stateData : new AnimationState(new AnimationStateData(skeletonData));
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
		if (!allowHiddenRender) {
			if (!this.visible || !isPlay)
				return;
		}
		_advanceTime(time);
	}

	/**
	 * 在updateWorldTransform调用之前发生
	 */
	dynamic public function onUpdateWorldTransformBefore():Void {}

	private function _advanceTime(time:Float):Void {
		time = time / timeScale;
		state.update(time);
		state.apply(skeleton);
		this.onUpdateWorldTransformBefore();
		skeleton.updateWorldTransform();
		super.advanceTime(time);
	}

	/**
	 * 播放动画
	 * @param action 动作名
	 * @param loop 是否循环
	 */
	override public function play(action:String = null, loop:Bool = true):Void {
		if (action != this.actionName) {
			if (action != null && action != "") {
				this.state.setAnimationByName(0, action, loop);
			}
			this._currentAnimation = getAnimation(action);
		}
		super.play(action);
	}

	override function get_isCache():Bool {
		if (state.tracks.length > 2) {
			return false;
		}
		return super.get_isCache();
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
		super.play(action);
		// _advanceTime(0);
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

	override function __getCurrentFrameId():Int {
		var current = state.getCurrent(0);
		if (current == null || state.tracks.length > 1)
			return -1;
		return Std.int(current.trackTime % _currentAnimation.duration / _currentAnimation.duration * Std.int(_currentAnimation.duration * 60));
	}
}
