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

import openfl.geom.ColorTransform;
import spine.base.SpineBaseDisplay;
import zygame.utils.SpineManager;
import openfl.display.BitmapData;
import spine.attachments.MeshAttachment;
import spine.Bone;
import spine.Skeleton;
import spine.SkeletonData;
import spine.Slot;
import spine.support.graphics.TextureAtlas;
import spine.attachments.RegionAttachment;
import spine.support.graphics.Color;
import openfl.display.TileContainer;
import openfl.display.Tile;
import openfl.events.Event;
import spine.BlendMode;
import spine.support.graphics.Color;

/**
 * Tilemap渲染器
 */
class SkeletonSprite extends TileContainer implements SpineBaseDisplay {
	public var skeleton:Skeleton;
	public var timeScale:Float = 1;

	// 坐标数组
	private var _tempVerticesArray:Array<Float>;

	private var _isPlay:Bool = true;

	private var _actionName:String = "";

	/**
	 * 渲染骨骼对应关系
	 */
	private var _map:Map<Slot, TileContainer>;

	public function new(skeletonData:SkeletonData) {
		super();

		skeleton = new Skeleton(skeletonData);
		skeleton.updateWorldTransform();

		_map = new Map<Slot, TileContainer>();

		SpineManager.addOnFrame(this);
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
		if (action != null)
			_actionName = action;
	}

	public function stop():Void {
		_isPlay = false;
	}

	public function advanceTime(delta:Float):Void {
		if (!_isPlay)
			return;
		skeleton.update(delta * timeScale);
		renderTriangles();
	}

	private function renderTriangles():Void {
		var drawOrder:Array<Slot> = skeleton.drawOrder;
		var n:Int = drawOrder.length;
		var triangles:Array<Int> = null;
		var uvs:Array<Float> = null;
		var atlasRegion:AtlasRegion;
		var bitmapData:BitmapData = null;
		var slot:Slot;
		var skeletonColor:Color;
		var soltColor:Color;
		var regionColor:Color;
		// var blend:Int;

		this.removeTiles();

		for (i in 0...n) {
			// if(i != 22)
			// continue;
			// 获取骨骼
			slot = drawOrder[i];
			// 初始化参数
			triangles = null;
			uvs = null;
			atlasRegion = null;
			bitmapData = null;
			// 如果骨骼的渲染物件存在
			if (slot.attachment != null) {
				if (Std.is(slot.attachment, RegionAttachment)) {
					// 如果是矩形
					var region:RegionAttachment = cast slot.attachment;
					regionColor = region.getColor();
					atlasRegion = cast region.getRegion();

					// 矩形绘制
					if (atlasRegion != null) {
						var wrapper:TileContainer = _map.get(slot);
						var tile:Tile = null;
						if (wrapper == null) {
							wrapper = new TileContainer();
							tile = new Tile(atlasRegion.page.rendererObject.getID(atlasRegion));
							wrapper.addTile(tile);
							// var tile2 = new Tile(atlasRegion.page.rendererObject.getID(atlasRegion));
							// tile2.scaleX = 2;
							// tile2.scaleY = 0.05;
							// wrapper.addTile(tile2);
							// tile2.x -= 40;
							// var tile2 = new Tile(atlasRegion.page.rendererObject.getID(atlasRegion));
							// tile2.scaleX = 2;
							// tile2.scaleY = 0.05;
							// wrapper.addTile(tile2);
							// tile2.y -= 40;
							// tile2.rotation = 90;
							_map.set(slot, wrapper);
						} else {
							tile = wrapper.getTileAt(0);
							tile.id = atlasRegion.page.rendererObject.getID(atlasRegion);
						}

						var regionHeight:Float = atlasRegion.rotate ? atlasRegion.width : atlasRegion.height;

						tile.rotation = -region.getRotation();
						tile.scaleX = region.getScaleX() * (region.getWidth() / atlasRegion.width);
						tile.scaleY = region.getScaleY() * (region.getHeight() / atlasRegion.height);

						var radians:Float = -region.getRotation() * Math.PI / 180;
						var cos:Float = Math.cos(radians);
						var sin:Float = Math.sin(radians);
						var shiftX:Float = -region.getWidth() / 2 * region.getScaleX();
						var shiftY:Float = -region.getHeight() / 2 * region.getScaleY();
						var offsetX:Float = atlasRegion.offsetX;
						var offsetY:Float = atlasRegion.offsetY;
						if (atlasRegion.rotate) {
							tile.rotation += 90;
							shiftX += regionHeight * (region.getWidth() / atlasRegion.width);
							var offset2 = offsetY;
							// offsetY = offsetX;
							// offsetX = offset2;
							// trace("rotate");
						}

						tile.x = region.getX() + shiftX * cos - shiftY * sin;
						tile.y = -region.getY() + shiftX * sin + shiftY * cos;
						// trace(atlasRegion.offsetX,atlasRegion.offsetY);
						// trace(atlasRegion.offsetX,atlasRegion.offsetY);
						// tile.x =  region.getX() +atlasRegion.offsetX;
						// tile.y = - region.getY()+atlasRegion.offsetY;

						var bone:Bone = slot.bone;
						#if (spine_hx <= "3.6.0")
						var flipX:Int = skeleton.flipX ? -1 : 1;
						var flipY:Int = skeleton.flipY ? -1 : 1;
						#else
						var flipX:Float = skeleton.getScaleX();
						var flipY:Float = skeleton.getScaleY();
						#end

						wrapper.x = bone.getWorldX();
						wrapper.y = bone.getWorldY();
						wrapper.rotation = bone.getWorldRotationX();
						wrapper.scaleX = bone.getWorldScaleX();
						wrapper.scaleY = bone.getWorldScaleY();
						this.addTile(wrapper);

						// 色值处理
						#if (openfl > "8.4.0")
						wrapper.alpha = slot.color.a * skeleton.color.a * region.getColor().a;
						if (wrapper.colorTransform == null) {
							wrapper.colorTransform = new ColorTransform();
						}
						wrapper.colorTransform.greenMultiplier = slot.color.r * skeleton.color.r * region.getColor().r;
						wrapper.colorTransform.greenMultiplier = slot.color.g * skeleton.color.g * region.getColor().g;
						wrapper.colorTransform.blueMultiplier = slot.color.b * skeleton.color.b * region.getColor().b;
						switch (slot.data.blendMode) {
							case BlendMode.additive:
								wrapper.blendMode = openfl.display.BlendMode.ADD;
							case BlendMode.multiply:
								wrapper.blendMode = openfl.display.BlendMode.MULTIPLY;
							case BlendMode.screen:
								wrapper.blendMode = openfl.display.BlendMode.SCREEN;
							case BlendMode.normal:
								wrapper.blendMode = openfl.display.BlendMode.NORMAL;
						}
						#end
					}
				} else if (Std.is(slot.attachment, MeshAttachment)) {
					throw "tilemap not support MeshAttachment!";
				}
			}
		}
	}

	public function argbToNumber(a:Int, r:Int, g:Int, b:Int):UInt {
		return a << 24 | r << 16 | g << 8 | b;
	}
}
