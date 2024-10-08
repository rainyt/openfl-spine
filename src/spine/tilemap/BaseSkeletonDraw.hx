package spine.tilemap;

#if zygame
import zygame.utils.FPSDebug;
import zygame.display.batch.BImage;
import zygame.display.batch.BSprite;
#end
import spine.attachments.MeshAttachment;
import openfl.geom.ColorTransform;
import openfl.display.Tile;
import openfl.display.TileContainer;
import spine.attachments.RegionAttachment;
import spine.Color;
import openfl.display.BitmapData;
import spine.atlas.TextureAtlasRegion;
import spine.base.SpineBaseDisplay;

/**
 * 基础的瓦片渲染Spine对象，只含骨骼渲染
 */
class BaseSkeletonDraw extends #if zygame BSprite #else TileContainer #end {
	public function new(skeleton:Skeleton) {
		super();
		this.skeleton = skeleton;
	}

	public var skeleton:Skeleton;

	/**
	 * 渲染骨骼对应关系
	 */
	private var _map:Map<Slot, TileContainer> = [];

	/**
	 * 禁用颜色
	 */
	public var disableColor:Bool = false;

	private function renderTriangles():Void {
		// removeTiles性能比较差，不适合频繁调用
		// this.removeTiles();
		for (key => value in _map) {
			this.removeTile(value);
		}

		// 不可见以及骨骼数据为null时，则不再渲染
		if (!this.visible || skeleton == null) {
			return;
		}

		#if (spine_hx <= "3.6.0")
		skeleton.setFlipY(true);
		#end

		var drawOrder:Array<Slot> = skeleton.drawOrder;
		var n:Int = drawOrder.length;
		var atlasRegion:TextureAtlasRegion;
		var bitmapData:BitmapData = null;
		var slot:Slot;
		var skeletonColor:Color;
		var soltColor:Color;
		var regionColor:Color;
		// var blend:Int;

		for (i in 0...n) {
			// 获取骨骼
			slot = drawOrder[i];
			// 初始化参数
			atlasRegion = null;
			bitmapData = null;
			// 如果骨骼的渲染物件存在
			if (slot.attachment != null) {
				if (Std.isOfType(slot.attachment, RegionAttachment)) {
					// 如果是矩形
					var region:RegionAttachment = cast slot.attachment;
					regionColor = region.color;
					atlasRegion = cast region.region;

					// 矩形绘制
					if (atlasRegion != null) {
						var wrapper:#if zygame BSprite #else TileContainer #end = cast _map.get(slot);
						var tile:#if zygame BImage #else Tile #end = null;
						if (wrapper == null) {
							wrapper = new
								#if zygame
								BSprite
								#else
								TileContainer
								#end();
							tile = new #if zygame BImage(atlasRegion.page.rendererObject.getFrameByRegion(atlasRegion)) #else Tile(atlasRegion.page.rendererObject.getID(atlasRegion)) #end;
							wrapper.addTile(tile);
							_map.set(slot, wrapper);
						} else {
							tile = cast wrapper.getTileAt(0);
							#if zygame
							tile.setFrame(atlasRegion.page.rendererObject.getFrameByRegion(atlasRegion));
							#else
							tile.id = atlasRegion.page.rendererObject.getID(atlasRegion);
							#end
						}

						var regionHeight:Float = atlasRegion.rotate ? atlasRegion.width : atlasRegion.height;

						tile.rotation = -region.rotation;
						tile.scaleX = region.scaleX * (region.width / atlasRegion.width);
						tile.scaleY = region.scaleY * (region.height / atlasRegion.height);

						var radians:Float = -region.rotation * Math.PI / 180;
						var cos:Float = Math.cos(radians);
						var sin:Float = Math.sin(radians);
						var shiftX:Float = -region.width / 2 * region.scaleX;
						var shiftY:Float = -region.height / 2 * region.scaleY;
						if (atlasRegion.rotate) {
							tile.rotation += 90;
							shiftX += regionHeight * (region.width / atlasRegion.width);
						}

						tile.x = region.x + shiftX * cos - shiftY * sin;
						tile.y = -region.y + shiftX * sin + shiftY * cos;

						var bone:Bone = slot.bone;
						wrapper.x = bone.worldX;
						wrapper.y = bone.worldY;
						wrapper.rotation = bone.worldRotationX;
						if (bone.scaleX < 0)
							wrapper.rotation -= 180;
						wrapper.scaleX = bone.worldScaleX * (bone.scaleX < 0 ? -1 : 1);
						wrapper.scaleY = bone.worldScaleY * (bone.scaleY < 0 ? -1 : 1);
						this.addTile(wrapper);

						// 色值处理
						if (!disableColor) {
							wrapper.alpha = slot.color.a * skeleton.color.a * region.color.a;
							if (wrapper.colorTransform == null) {
								wrapper.colorTransform = new ColorTransform();
							}
							wrapper.colorTransform.greenMultiplier = slot.color.r * skeleton.color.r * region.color.r;
							wrapper.colorTransform.greenMultiplier = slot.color.g * skeleton.color.g * region.color.g;
							wrapper.colorTransform.blueMultiplier = slot.color.b * skeleton.color.b * region.color.b;
						}
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
					}
				} else if (Std.isOfType(slot.attachment, MeshAttachment)) {
					throw "tilemap not support MeshAttachment!";
				}
			}
		}
	}

	public function argbToNumber(a:Int, r:Int, g:Int, b:Int):UInt {
		return a << 24 | r << 16 | g << 8 | b;
	}
}
