package spine.tilemap;

import spine.support.graphics.TextureAtlas;
import openfl.display.BitmapData;
import openfl.Assets;
import spine.support.graphics.TextureLoader;
import openfl.display.Tileset;
import openfl.geom.Rectangle;

class BitmapDataTextureLoader implements TextureLoader {
	var prefix:String;

	private var _tileset:Tileset;

	private var _ids:Map<AtlasRegion,Int>;

	public function new(prefix:String) {
		this.prefix = prefix;
	}

	public function loadPage (page:AtlasPage, path:String):Void {
		var bitmapData:BitmapData = Assets.getBitmapData(prefix + path);
		if (bitmapData == null)
			throw new IllegalArgumentException("BitmapData not found with name: " + prefix + path);
		_tileset = new Tileset(bitmapData);
		_ids = new Map<AtlasRegion,Int>();
		page.rendererObject = this;
		page.width = bitmapData.width;
		page.height = bitmapData.height;
	}

	public function loadRegion (region:AtlasRegion):Void {
		var regionWidth:Float = region.rotate ? region.height : region.width;
		var regionHeight:Float = region.rotate ? region.width : region.height;
		var id:Int = _tileset.addRect(new Rectangle(region.x,region.y,regionWidth,regionHeight));
		_ids.set(region,id);
		trace("追加尺寸：",id,region.x,region.y,region.width,region.height);
	}

	/**
	 * 获取渲染ID
	 * @param region 
	 * @return Int
	 */
	public function getID(region:AtlasRegion):Int
	{
		return _ids.get(region);
	}

	public function getTileset():Tileset
	{
		return _tileset;
	}

	public function unloadPage (page:AtlasPage):Void {
		// page.rendererObject.dispose();
	}
}