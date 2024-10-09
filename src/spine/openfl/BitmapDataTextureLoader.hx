package spine.openfl;

import spine.atlas.TextureAtlasPage;
import spine.atlas.TextureAtlasRegion;
import spine.atlas.TextureAtlas;
import openfl.display.BitmapData;
import spine.atlas.TextureLoader;
import zygame.utils.StringUtils;

@:keep
class BitmapDataTextureLoader implements TextureLoader {
	private var _bitmapData:Map<String, BitmapData>;

	private var _regions:Map<String, TextureAtlasRegion> = [];

	public function new(bitmapData:Map<String, BitmapData>) {
		this._bitmapData = bitmapData;
	}

	public function loadPage(page:TextureAtlasPage, path:String):Void {
		var bitmapData:BitmapData = this._bitmapData.get(StringUtils.getName(path));
		if (bitmapData == null)
			throw("BitmapData not found with name: " + path);
		page.texture = bitmapData;
		page.width = bitmapData.width;
		page.height = bitmapData.height;
	}

	public function getRegionByName(name:String):TextureAtlasRegion {
		return _regions.get(name);
	}

	public function loadRegion(region:TextureAtlasRegion):Void {
		_regions.set(region.name, region);
		#if !spine4
		if (region.offsetX == 0 && region.offsetY == 0)
			return;
		var rotate = region.degrees != 0;
		if (rotate) {
			var v1:Int = region.width;
			region.width = region.height;
			region.height = v1;

			v1 = region.originalHeight;
			region.originalHeight = region.originalWidth;
			region.originalWidth = v1;

			v1 = region.originalHeight;
			region.originalHeight = region.originalWidth;
			region.originalWidth = v1;
		}
		if (region.originalWidth == region.originalWidth
			&& region.originalHeight == region.originalHeight
			|| (region.width < region.originalWidth && region.height < region.originalHeight)) {
			if (region.width < region.originalWidth) {
				region.originalWidth = region.width;
			}
			if (region.height < region.originalHeight) {
				region.originalHeight = region.height;
			}
		} else {
			if (region.height < region.originalWidth) {
				region.originalWidth = region.height;
			}
			if (region.width < region.originalHeight) {
				region.originalHeight = region.width;
			}
		}
		#end
	}

	public function unloadPage(page:TextureAtlasPage):Void {
		page.texture.dispose();
	}
}
