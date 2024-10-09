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
	}

	public function unloadPage(page:TextureAtlasPage):Void {
		page.texture.dispose();
	}
}
