package spine.openfl;

import spine.support.graphics.TextureAtlas;
import openfl.display.BitmapData;
import openfl.Assets;
import spine.support.graphics.TextureLoader;
import openfl.geom.Rectangle;

class BitmapDataTextureLoader implements TextureLoader {
	var prefix:String;

	private var _ids:Map<AtlasRegion,Int>;

	public function new(prefix:String) {
		this.prefix = prefix;
	}

	public function loadPage (page:AtlasPage, path:String):Void {
		var bitmapData:BitmapData = Assets.getBitmapData(prefix + path);
		if (bitmapData == null)
			throw new IllegalArgumentException("BitmapData not found with name: " + prefix + path);
		_ids = new Map<AtlasRegion,Int>();
		page.rendererObject = bitmapData;
		page.width = bitmapData.width;
		page.height = bitmapData.height;
	}

	public function loadRegion (region:AtlasRegion):Void {
		// var regionWidth:Float = region.rotate ? region.height : region.width;
		// var regionHeight:Float = region.rotate ? region.width : region.height;
		// var id:Int = _tileset.addRect(new Rectangle(region.x,region.y,regionWidth,regionHeight));
		// _ids.set(region,id);
		// trace("追加尺寸：",id,region.x,region.y,region.width,region.height);
	}

	public function unloadPage (page:AtlasPage):Void {
		// page.rendererObject.dispose();
	}
}

class SkeletonDataFileHandle implements spine.support.files.FileHandle {

	public var path:String = "";

	private var _data:String;

	public function new(path:String,data:String = null){
		this.path = path;
		_data = data;
		if(_data == null)
			_data = openfl.Assets.getText(path);
	}

	public function getContent():String{
		return _data;
	}

}