package spine.openfl;

import spine.support.graphics.TextureAtlas;
import openfl.display.BitmapData;
import spine.support.graphics.TextureLoader;
import zygame.utils.StringUtils;

@:keep
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
		if(region.offsetX == 0 && region.offsetY == 0)
			return;
		if(region.rotate)
		{
			var v1:Int = region.width;
			region.width = region.height;
			region.height = v1;

			v1 = region.originalHeight;
			region.originalHeight = region.originalWidth;
			region.originalWidth = v1;

			v1 = region.packedHeight;
			region.packedHeight = region.packedWidth;
			region.packedWidth = v1;

		}
	}

	public function unloadPage (page:AtlasPage):Void {
		page.rendererObject.dispose();
	}
	
}
