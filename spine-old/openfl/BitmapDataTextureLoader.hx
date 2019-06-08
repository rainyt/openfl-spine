package spine.openfl;

import spine.support.graphics.TextureAtlas;
import openfl.display.BitmapData;
import openfl.Assets;
import spine.support.graphics.TextureLoader;

class BitmapDataTextureLoader implements TextureLoader {

	private var _bitmapData:Map<String,BitmapData>;

	public function new(bitmapData:Map<String,BitmapData>) {
		this._bitmapData = bitmapData;
	}

	public function loadPage (page:AtlasPage, path:String):Void {
		var bitmapData:BitmapData = this._bitmapData.get(getName(path));
		if (bitmapData == null)
			throw new IllegalArgumentException("BitmapData not found with name: " + path);
		page.rendererObject = bitmapData;
		page.width = bitmapData.width;
		page.height = bitmapData.height;
	}

	public function loadRegion (region:AtlasRegion):Void {
	}

	public function unloadPage (page:AtlasPage):Void {
		page.rendererObject.dispose();
	}

	/**
     *  获取字符串的名字，不带路径、扩展名
     *  @param data - 
     *  @return String
     */
    public static function getName(data:String):String
    {
        if(data == null)
            return data;
        data = data.substr(data.lastIndexOf("/")+1);
        data = data.substr(0,data.lastIndexOf("."));
        return data;
    }
}