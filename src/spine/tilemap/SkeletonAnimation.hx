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

package spine.tilemap;

import spine.events.AnimationEvent;
import spine.SkeletonData;
import spine.animation.AnimationState;
import spine.animation.AnimationStateData;

class SkeletonAnimation extends SkeletonSprite {
	#if zygame
	/**
	 * 资源索引
	 */
	public var assetsId:String = null;
	#end

	public var state:AnimationState;

	public function new(skeletonData:SkeletonData, stateData:AnimationStateData = null) {
		super(skeletonData);
		#if (spine_hx <= "3.6.0")
		skeleton.setFlipY(true);
		#else
		skeleton.scaleY = -1;
		#end
		state = new AnimationState(stateData == null ? new AnimationStateData(skeletonData) : stateData);
		_advanceTime(0);
	}

	override public function advanceTime(time:Float):Void {
		if (!this.visible || !isPlay)
			return;
		_advanceTime(time);
	}

	private function _advanceTime(time:Float) {
		state.update(time / timeScale);
		state.apply(skeleton);
		super.advanceTime(time);
	}

	/**
	 * 播放
	 */
	override public function play(action:String = null, loop:Bool = true):Void {
		if (action != null && action != "") {
			this.state.setAnimationByName(0, action, loop);
		}
		super.play(action);
	}

	#if zygame
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
			_event.addEventListener(type, listener);
	}
	#end
}
