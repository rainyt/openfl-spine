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
 * Tilemap-based SkeletonSprite for Spine rendering
 * Implements SpineBaseDisplay interface
 */
#else
/**
 * 基于瓦片的Spine渲染器
 * 实现SpineBaseDisplay接口
 */
#end
package spine.tilemap;

import spine.base.SpineBaseDisplay;
import zygame.utils.SpineManager;
import spine.Skeleton;
import spine.SkeletonData;

class SkeletonSprite extends BaseSkeletonDraw implements SpineBaseDisplay {
	#if api_lang_en
	/**
	 * Time scale for animation
	 */
	#else
	/**
	 * 动画时间缩放
	 */
	#end
	public var timeScale:Float = 1;

	#if api_lang_en
	/**
	 * Whether animation is playing
	 */
	#else
	/**
	 * 是否正在播放动画
	 */
	#end
	private var _isPlay:Bool = true;

	#if api_lang_en
	/**
	 * Current action name
	 */
	#else
	/**
	 * 当前动作名称
	 */
	#end
	private var _actionName:String = "";

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
	 * Checks if the sprite is hidden
	 * @return True if hidden
	 */
	#else
	/**
	 * 检查精灵是否隐藏
	 * @return 如果隐藏返回true
	 */
	#end
	public function isHidden():Bool {
		return this.alpha == 0 || !this.visible;
	}

	#if api_lang_en
	/**
	 * Creates a new SkeletonSprite
	 * @param skeletonData Skeleton data
	 */
	#else
	/**
	 * 创建一个新的SkeletonSprite
	 * @param skeletonData 骨骼数据
	 */
	#end
	public function new(skeletonData:SkeletonData) {
		super(new Skeleton(skeletonData));
		#if spine4_2
		this.skeleton.updateWorldTransform(Physics.update);
		#else
		this.skeleton.updateWorldTransform();
		#end
		#if zygame
		this.mouseChildren = false;
		#end
	}

	#if api_lang_en
	/**
	 * Unified Spine update
	 * @param dt Delta time
	 */
	#else
	/**
	 * 统一Spine更新
	 * @param dt 增量时间
	 */
	#end
	public function onSpineUpdate(dt:Float):Void {
		advanceTime(dt);
	}

	#if api_lang_en
	/**
	 * Destroys the sprite
	 */
	#else
	/**
	 * 销毁精灵
	 */
	#end
	public function destroy():Void {
		SpineManager.removeOnFrame(this);
		this.removeTiles();
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
	 * @return True if playing
	 */
	#else
	/**
	 * 获取是否正在播放
	 * @return 如果正在播放返回true
	 */
	#end
	private function get_isPlay():Bool {
		if (actionName == "" || actionName == null)
			return false;
		return _isPlay;
	}

	#if api_lang_en
	/**
	 * Sets whether animation is playing
	 * @param bool Whether to play
	 * @return The new value
	 */
	#else
	/**
	 * 设置是否正在播放
	 * @param bool 是否播放
	 * @return 新值
	 */
	#end
	private function set_isPlay(bool:Bool):Bool {
		_isPlay = bool;
		return bool;
	}

	#if api_lang_en
	/**
	 * Gets current action name
	 */
	#else
	/**
	 * 获取当前播放的动作
	 */
	#end
	public var actionName(get, never):String;

	#if api_lang_en
	/**
	 * Gets current action name
	 * @return Action name
	 */
	#else
	/**
	 * 获取当前动作名称
	 * @return 动作名称
	 */
	#end
	private function get_actionName():String {
		return _actionName;
	}

	#if api_lang_en
	/**
	 * Plays an action
	 * @param action Action name
	 * @param loop Whether to loop
	 */
	#else
	/**
	 * 播放动作
	 * @param action 动作名称
	 * @param loop 是否循环
	 */
	#end
	public function play(action:String = null, loop:Bool = true):Void {
		_isPlay = true;
		if (this.visible)
			SpineManager.addOnFrame(this);
		if (action != null)
			_actionName = action;
		this.advanceTime(0);
	}

	#if api_lang_en
	/**
	 * Stops animation
	 */
	#else
	/**
	 * 停止动画
	 */
	#end
	public function stop():Void {
		_isPlay = false;
		SpineManager.removeOnFrame(this);
	}

	#if api_lang_en
	/**
	 * Advances animation time
	 * @param delta Time to advance
	 */
	#else
	/**
	 * 推进动画时间
	 * @param delta 推进的时间
	 */
	#end
	public function advanceTime(delta:Float):Void {
		if (!_isPlay)
			return;
		skeleton.update(delta * timeScale);
		#if spine4_2
		skeleton.updateWorldTransform(Physics.update);
		#else
		skeleton.updateWorldTransform();
		#end
		renderTriangles();
	}

	#if api_lang_en
	/**
	 * Overrides visible property setter
	 * @param value Whether to make visible
	 * @return The new value
	 */
	#else
	/**
	 * 重写visible属性设置器
	 * @param value 是否可见
	 * @return 新值
	 */
	#end
	override private function set_visible(value:Bool):Bool {
		if (!value) {
			SpineManager.removeOnFrame(this);
		} else if (_isPlay) {
			SpineManager.addOnFrame(this);
		}
		return super.set_visible(value);
	}
}
