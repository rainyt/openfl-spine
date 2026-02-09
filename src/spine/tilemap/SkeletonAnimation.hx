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

#if api_lang_en
/**
 * Tilemap-based SkeletonAnimation for Spine animations
 * Extends SkeletonSprite to add animation state management
 */
#else
/**
 * 基于瓦片的Spine动画播放器
 * 扩展SkeletonSprite以添加动画状态管理
 */
#end
package spine.tilemap;

import spine.events.AnimationEvent;
import spine.SkeletonData;
#if spine4_2
import spine.animation.AnimationState;
import spine.animation.AnimationStateData;
#else
import spine.AnimationState;
import spine.AnimationStateData;
#end

class SkeletonAnimation extends SkeletonSprite {
	#if zygame
	#if api_lang_en
	/**
	 * Asset index
	 */
	#else
	/**
	 * 资源索引
	 */
	#end
	public var assetsId:String = null;
	#end

	#if api_lang_en
	/**
	 * Animation state for managing animations
	 */
	#else
	/**
	 * 用于管理动画的动画状态
	 */
	#end
	public var state:AnimationState;

	#if api_lang_en
	/**
	 * Creates a new SkeletonAnimation
	 * @param skeletonData Skeleton data
	 * @param stateData Animation state data (optional)
	 */
	#else
	/**
	 * 创建一个新的SkeletonAnimation
	 * @param skeletonData 骨骼数据
	 * @param stateData 动画状态数据（可选）
	 */
	#end
	public function new(skeletonData:SkeletonData, stateData:AnimationStateData = null) {
		super(skeletonData);
		#if (spine_hx <= "3.6.0")
		skeleton.setFlipY(true);
		#else
		#if spine4_2
		skeleton.scaleY = -1;
		#else
		skeleton.setScaleY(-1);
		#end
		#end
		state = new AnimationState(stateData == null ? new AnimationStateData(skeletonData) : stateData);
		_advanceTime(0);
	}

	#if api_lang_en
	/**
	 * Advances animation time
	 * @param time Time to advance in seconds
	 */
	#else
	/**
	 * 推进动画时间
	 * @param time 推进的时间（秒）
	 */
	#end
	override public function advanceTime(time:Float):Void {
		if (!this.visible || !isPlay)
			return;
		_advanceTime(time);
	}

	#if api_lang_en
	/**
	 * Internal method to advance time
	 * @param time Time to advance in seconds
	 */
	#else
	/**
	 * 内部方法，用于推进时间
	 * @param time 推进的时间（秒）
	 */
	#end
	private function _advanceTime(time:Float) {
		state.update(time / timeScale);
		state.apply(skeleton);
		#if !spine4_2
		skeleton.updateWorldTransform();
		#end
		super.advanceTime(time);
	}

	#if api_lang_en
	/**
	 * Plays an animation
	 * @param action Animation name
	 * @param loop Whether to loop the animation
	 */
	#else
	/**
	 * 播放
	 * @param action 动画名称
	 * @param loop 是否循环播放
	 */
	#end
	override public function play(action:String = null, loop:Bool = true):Void {
		if (action != null && action != "") {
			this.state.setAnimationByName(0, action, loop);
		}
		super.play(action);
	}

	#if zygame
	#if api_lang_en
	/**
	 * Animation event handler
	 */
	#else
	/**
	 * 动画事件处理器
	 */
	#end
	private var _event:AnimationEvent;

	#if api_lang_en
	/**
	 * Adds an event listener
	 * @param type Event type
	 * @param listener Event listener
	 * @param useCapture Use capture phase
	 * @param priority Event priority
	 * @param useWeakReference Use weak reference
	 */
	#else
	/**
	 * 添加事件监听器
	 * @param type 事件类型
	 * @param listener 事件监听器
	 * @param useCapture 是否使用捕获阶段
	 * @param priority 事件优先级
	 * @param useWeakReference 是否使用弱引用
	 */
	#end
	override function addEventListener<T>(type:openfl.events.EventType<T>, listener:T->Void, useCapture:Bool = false, priority:Int = 0,
			useWeakReference:Bool = false) {
		if (_event == null && state != null) {
			_event = new AnimationEvent();
			#if spine4_2
			// 添加事件侦听处理
			this.state.onStart.add(_event.start);
			this.state.onComplete.add(_event.complete);
			this.state.onDispose.add(_event.dispose);
			this.state.onEnd.add(_event.end);
			this.state.onInterrupt.add(_event.interrupt);
			this.state.onEvent.add(_event.event);
			#else
			this.state.addListener(_event);
			#end
		}
		if (_event != null)
			_event.addEventListener(type, listener);
		super.addEventListener(type, listener, useCapture, priority, useWeakReference);
	}

	#if api_lang_en
	/**
	 * Removes an event listener
	 * @param type Event type
	 * @param listener Event listener
	 * @param useCapture Use capture phase
	 */
	#else
	/**
	 * 移除事件监听器
	 * @param type 事件类型
	 * @param listener 事件监听器
	 * @param useCapture 是否使用捕获阶段
	 */
	#end
	override function removeEventListener<T>(type:openfl.events.EventType<T>, listener:T->Void, useCapture:Bool = false) {
		super.removeEventListener(type, listener, useCapture);
		if (_event != null)
			_event.addEventListener(type, listener);
	}
	#end
}
