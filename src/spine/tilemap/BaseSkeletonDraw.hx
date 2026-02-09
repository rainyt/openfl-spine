#if api_lang_en
/**
 * Base tilemap render for Spine
 * Only contains skeleton rendering functionality
 */
#else
/**
 * 基础的瓦片渲染Spine对象，只含骨骼渲染
 */
#end
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
#if spine4_2
import spine.Color;
import spine.atlas.TextureAtlasRegion;
import spine.Bone;
import spine.Slot;
import spine.Skeleton;
import spine.BlendMode;
#else
import spine.support.graphics.Color;
import spine.support.graphics.TextureAtlas.AtlasRegion as TextureAtlasRegion;
import spine.Bone;
import spine.Slot;
import spine.Skeleton;
import spine.BlendMode;
#end
import openfl.display.BitmapData;
import spine.base.SpineBaseDisplay;

class BaseSkeletonDraw extends #if zygame BSprite #else TileContainer #end {
	#if api_lang_en
	/**
	 * Creates a new BaseSkeletonDraw
	 * @param skeleton Skeleton to render
	 */
	#else
	/**
	 * 创建一个新的BaseSkeletonDraw
	 * @param skeleton 要渲染的骨骼
	 */
	#end
	public function new(skeleton:Skeleton) {
		super();
		this.skeleton = skeleton;
	}

	#if api_lang_en
	/**
	 * Skeleton object to render
	 */
	#else
	/**
	 * 要渲染的骨骼对象
	 */
	#end
	public var skeleton:Skeleton;

	#if api_lang_en
	/**
	 * Mapping of slots to tile containers for rendering
	 */
	#else
	/**
	 * 渲染骨骼对应关系
	 */
	#end
	private var _map:Map<Slot, TileContainer> = [];

	#if api_lang_en
	/**
	 * Whether to disable color processing
	 */
	#else
	/**
	 * 禁用颜色
	 */
	#end
	public var disableColor:Bool = false;

	#if api_lang_en
	/**
	 * Renders the skeleton using tiles
	 */
	#else
	/**
	 * 使用瓦片渲染骨骼
	 */
	#end
	private function renderTriangles():Void {
		// removeTiles has poor performance, not suitable for frequent calls
		// this.removeTiles();
		for (key => value in _map) {
			this.removeTile(value);
		}

		// Don't render if not visible or skeleton is null
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
		#if spine4_2
		for (i in 0...n) {
			// Get slot
			slot = drawOrder[i];
			// Initialize parameters
			atlasRegion = null;
			bitmapData = null;
			// If slot has attachment
			if (slot.attachment != null) {
				if (Std.isOfType(slot.attachment, RegionAttachment)) {
					// If it's a region attachment
					var region:RegionAttachment = cast slot.attachment;
					regionColor = region.color;
					atlasRegion = cast region.region;

					// Draw region
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
							tile = new #if zygame BImage(atlasRegion.page.texture.getFrameByRegion(atlasRegion)) #else Tile(atlasRegion.page.texture.getID(atlasRegion)) #end;
							wrapper.addTile(tile);
							_map.set(slot, wrapper);
						} else {
							tile = cast wrapper.getTileAt(0);
							#if zygame
							tile.setFrame(atlasRegion.page.texture.getFrameByRegion(atlasRegion));
							#else
							tile.id = atlasRegion.page.texture.getID(atlasRegion);
							#end
						}

						var regionHeight:Float = atlasRegion.degrees != 0 ? atlasRegion.width : atlasRegion.height;

						tile.rotation = -region.rotation;
						tile.scaleX = region.scaleX * (region.width / atlasRegion.width);
						tile.scaleY = region.scaleY * (region.height / atlasRegion.height);

						var radians:Float = -region.rotation * Math.PI / 180;
						var cos:Float = Math.cos(radians);
						var sin:Float = Math.sin(radians);
						var shiftX:Float = -region.width / 2 * region.scaleX;
						var shiftY:Float = -region.height / 2 * region.scaleY;
						if (atlasRegion.degrees != 0) {
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

						// Color processing
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
		#else
		for (i in 0...n) {
			// Get slot
			slot = drawOrder[i];
			// Initialize parameters
			atlasRegion = null;
			bitmapData = null;
			// If slot has attachment
			if (slot.attachment != null) {
				if (Std.isOfType(slot.attachment, RegionAttachment)) {
					// If it's a region attachment
					var region:RegionAttachment = cast slot.attachment;
					regionColor = region.getColor();
					atlasRegion = cast region.getRegion();

					// Draw region
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

						tile.rotation = -region.getRotation();
						tile.scaleX = region.getScaleX() * (region.getWidth() / atlasRegion.width);
						tile.scaleY = region.getScaleY() * (region.getHeight() / atlasRegion.height);

						var radians:Float = -region.getRotation() * Math.PI / 180;
						var cos:Float = Math.cos(radians);
						var sin:Float = Math.sin(radians);
						var shiftX:Float = -region.getWidth() / 2 * region.getScaleX();
						var shiftY:Float = -region.getHeight() / 2 * region.getScaleY();
						if (atlasRegion.rotate) {
							tile.rotation += 90;
							shiftX += regionHeight * (region.getWidth() / atlasRegion.width);
						}

						tile.x = region.getX() + shiftX * cos - shiftY * sin;
						tile.y = -region.getY() + shiftX * sin + shiftY * cos;

						var bone:Bone = slot.bone;
						wrapper.x = bone.getWorldX();
						wrapper.y = bone.getWorldY();
						wrapper.rotation = bone.getWorldRotationX();
						if (bone.getScaleX() < 0)
							wrapper.rotation -= 180;
						wrapper.scaleX = bone.getWorldScaleX() * (bone.getScaleX() < 0 ? -1 : 1);
						wrapper.scaleY = bone.getWorldScaleY() * (bone.getScaleY() < 0 ? -1 : 1);
						this.addTile(wrapper);

						// Color processing
						if (!disableColor) {
							wrapper.alpha = slot.color.a * skeleton.color.a * region.getColor().a;
							if (wrapper.colorTransform == null) {
								wrapper.colorTransform = new ColorTransform();
							}
							wrapper.colorTransform.greenMultiplier = slot.color.r * skeleton.color.r * region.getColor().r;
							wrapper.colorTransform.greenMultiplier = slot.color.g * skeleton.color.g * region.getColor().g;
							wrapper.colorTransform.blueMultiplier = slot.color.b * skeleton.color.b * region.getColor().b;
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
		#end
	}

	#if api_lang_en
	/**
	 * Converts ARGB color values to a single number
	 * @param a Alpha component
	 * @param r Red component
	 * @param g Green component
	 * @param b Blue component
	 * @return ARGB color as a single number
	 */
	#else
	/**
	 * 将ARGB颜色值转换为单个数字
	 * @param a  alpha分量
	 * @param r  红色分量
	 * @param g  绿色分量
	 * @param b  蓝色分量
	 * @return 单个数字表示的ARGB颜色
	 */
	#end
	public function argbToNumber(a:Int, r:Int, g:Int, b:Int):UInt {
		return a << 24 | r << 16 | g << 8 | b;
	}
}
