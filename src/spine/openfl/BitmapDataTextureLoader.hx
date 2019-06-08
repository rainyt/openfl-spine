package spine.openfl;

import spine.support.graphics.TextureAtlas;
import openfl.display.BitmapData;
import openfl.Assets;
import spine.support.graphics.TextureLoader;
import zygame.utils.StringUtils;

class BitmapDataTextureLoader implements TextureLoader {

	private var _bitmapData:Map<String,BitmapData>;

	public function new(bitmapData:Map<String,BitmapData>) {
		this._bitmapData = bitmapData;
	}

	public function loadPage (page:AtlasPage, path:String):Void {
		var bitmapData:BitmapData = this._bitmapData.get(StringUtils.getName(path));
		if (bitmapData == null)
			throw ("BitmapData not found with name: " + path);
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