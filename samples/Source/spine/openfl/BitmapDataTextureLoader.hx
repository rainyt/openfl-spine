package spine.openfl;

import spine.support.graphics.TextureAtlas;
import openfl.display.BitmapData;
import openfl.Assets;
import spine.support.graphics.TextureLoader;

class BitmapDataTextureLoader implements TextureLoader {

	private var _bitmapData:BitmapData;

	private var _ids:Map<AtlasRegion,Int>;

	public function new(bitmapData:BitmapData) {
		this._bitmapData = bitmapData;
	}

	public function loadPage (page:AtlasPage, path:String):Void {
		var bitmapData:BitmapData = this._bitmapData;
		if (bitmapData == null)
			throw new IllegalArgumentException("BitmapData not found with name: " + path);
		_ids = new Map<AtlasRegion,Int>();
		page.rendererObject = bitmapData;
		page.width = bitmapData.width;
		page.height = bitmapData.height;
	}

	public function loadRegion (region:AtlasRegion):Void {
	}

	public function unloadPage (page:AtlasPage):Void {
		page.rendererObject.dispose();
	}
}