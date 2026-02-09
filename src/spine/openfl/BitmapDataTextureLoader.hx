package spine.openfl;

#if spine4_2
import spine.atlas.TextureAtlasPage;
import spine.atlas.TextureAtlasRegion;
import spine.atlas.TextureAtlas;
import spine.atlas.TextureLoader;
#else
import spine.support.graphics.TextureAtlas;
import spine.support.graphics.TextureLoader;
#end
import openfl.display.BitmapData;
import zygame.utils.StringUtils;

@:keep
class BitmapDataTextureLoader implements TextureLoader {
	private var _bitmapData:Map<String, BitmapData>;

	private var _regions:Map<String, #if spine4_2 TextureAtlasRegion #else AtlasRegion #end> = [];

	public function new(bitmapData:Map<String, BitmapData>) {
		this._bitmapData = bitmapData;
	}

	public function loadPage(page:#if spine4_2 TextureAtlasPage #else AtlasPage #end, path:String):Void {
		var bitmapData:BitmapData = this._bitmapData.get(StringUtils.getName(path));
		if (bitmapData == null)
			throw("BitmapData not found with name: " + path);
		#if !spine4_2
		page.rendererObject = bitmapData;
		#else
		page.texture = bitmapData;
		#end
		page.width = bitmapData.width;
		page.height = bitmapData.height;
	}

	public function getRegionByName(name:String):#if spine4_2 TextureAtlasRegion #else AtlasRegion #end {
		return _regions.get(name);
	}

	public function loadRegion(region:#if spine4_2 TextureAtlasRegion #else AtlasRegion #end):Void {
		_regions.set(region.name, region);
		#if !spine4_2
		if (region.offsetX == 0 && region.offsetY == 0)
			return;
		if (region.rotate) {
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
		if (region.originalWidth == region.packedWidth
			&& region.originalHeight == region.packedHeight
			|| (region.width < region.packedWidth && region.height < region.packedHeight)) {
			if (region.width < region.originalWidth) {
				region.packedWidth = region.width;
			}
			if (region.height < region.originalHeight) {
				region.packedHeight = region.height;
			}
		} else {
			if (region.height < region.originalWidth) {
				region.packedWidth = region.height;
			}
			if (region.width < region.originalHeight) {
				region.packedHeight = region.width;
			}
		}
		#end
	}

	public function unloadPage(page:#if spine4_2 TextureAtlasPage #else AtlasPage #end):Void {
		#if !spine4_2
		page.rendererObject.dispose();
		#else
		page.texture.dispose();
		#end
	}
}
