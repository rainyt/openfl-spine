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

import spine.base.SpineBaseDisplay;
import zygame.utils.SpineManager;
import spine.Skeleton;
import spine.SkeletonData;

/**
 * Tilemap渲染器
 */
class SkeletonSprite extends BaseSkeletonDraw implements SpineBaseDisplay {
	public var timeScale:Float = 1;

	private var _isPlay:Bool = true;

	private var _actionName:String = "";

	/**
	 * 最后绘制时间
	 */
	public var lastDrawTime:Float = 0;

	/**
	 * 是否为独立运行，不受SpineManager的影响
	 */
	public var independent:Bool = false;

	public function isHidden():Bool {
		return this.alpha == 0 || !this.visible;
	}

	public function new(skeletonData:SkeletonData) {
		super(new Skeleton(skeletonData));
		this.skeleton.updateWorldTransform(Physics.update);
		#if zygame
		this.mouseChildren = false;
		#end
	}

	/**
	 * 统一Spine更新
	 */
	public function onSpineUpdate(dt:Float):Void {
		advanceTime(dt);
	}

	public function destroy():Void {
		SpineManager.removeOnFrame(this);
		this.removeTiles();
	}

	/**
	 * 是否正在播放
	 */
	public var isPlay(get, set):Bool;

	private function get_isPlay():Bool {
		if (actionName == "" || actionName == null)
			return false;
		return _isPlay;
	}

	private function set_isPlay(bool:Bool):Bool {
		_isPlay = bool;
		return bool;
	}

	/**
	 * 获取当前播放的动作
	 */
	public var actionName(get, never):String;

	private function get_actionName():String {
		return _actionName;
	}

	public function play(action:String = null, loop:Bool = true):Void {
		_isPlay = true;
		if (this.visible)
			SpineManager.addOnFrame(this);
		if (action != null)
			_actionName = action;
		this.advanceTime(0);
	}

	public function stop():Void {
		_isPlay = false;
		SpineManager.removeOnFrame(this);
	}

	public function advanceTime(delta:Float):Void {
		if (!_isPlay)
			return;
		skeleton.update(delta * timeScale);
		skeleton.updateWorldTransform(Physics.update);
		renderTriangles();
	}

	override private function set_visible(value:Bool):Bool {
		if (!value) {
			SpineManager.removeOnFrame(this);
		} else if (_isPlay) {
			SpineManager.addOnFrame(this);
		}
		return super.set_visible(value);
	}
}
