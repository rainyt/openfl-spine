package spine.tilemap;

#if zygame
import zygame.utils.load.Frame;
#end
import spine.support.graphics.TextureAtlas;
import openfl.display.BitmapData;
import openfl.Assets;
import spine.support.graphics.TextureLoader;
import openfl.display.Tileset;
import openfl.geom.Rectangle;
import zygame.utils.StringUtils;

@:keep
class BitmapDataTextureLoader implements TextureLoader {
	private var _bitmapData:Map<String, BitmapData>;

	private var _tileset:Tileset;

	private var _atlasRegionMaps:Map<String, AtlasRegion>;

	private var _ids:Map<AtlasRegion, Int>;

	// private var _widths:Map<AtlasRegion, Float>;

	#if zygame
	/**
	 * 可用于批渲染使用的图集内容
	 */
	public var frameMaps:Map<String, Frame> = [];

	public var frameMapsIds:Map<Int, Frame> = [];
	#end

	public function new(bitmapDatas:Map<String, BitmapData>) {
		this._bitmapData = bitmapDatas;
	}

	public function loadPage(page:AtlasPage, path:String):Void {
		var bitmapData:BitmapData = this._bitmapData.get(StringUtils.getName(path));
		if (bitmapData == null)
			throw("BitmapData not found with name: " + path);
		_tileset = new Tileset(bitmapData);
		_ids = new Map<AtlasRegion, Int>();
		_atlasRegionMaps = [];
		// _widths = [];
		page.rendererObject = this;
		page.width = bitmapData.width;
		page.height = bitmapData.height;
	}

	public function loadRegion(region:AtlasRegion):Void {
		var regionWidth:Int = region.rotate ? region.height : region.width;
		var regionHeight:Int = region.rotate ? region.width : region.height;
		// _widths.set(region, region.width);
		_atlasRegionMaps.set(region.name, region);
		var rect = new Rectangle(region.x, region.y, regionWidth, regionHeight);
		var id:Int = _tileset.addRect(rect);
		_ids.set(region, id);
		if (!region.rotate) {
			region.width = region.packedWidth;
			region.height = region.packedHeight;
		} else {
			region.height = region.packedWidth;
			region.width = region.packedHeight;
		}
		#if zygame
		// 批渲染帧
		var frame = new Frame(null);
		frame.x = rect.x;
		frame.y = rect.y;
		frame.width = rect.width;
		frame.height = rect.height;
		if (region.rotate) {
			frame.width = rect.height;
			frame.height = rect.width;
		}
		frame.name = region.name;
		frame.rotate = region.rotate;
		frame.id = id;
		frameMaps.set(region.name, frame);
		frameMapsIds.set(id, frame);
		#end
	}

	public function getRegionByName(name:String):AtlasRegion {
		return _atlasRegionMaps.get(name);
	}

	#if zygame
	public function getFrameByRegion(region:AtlasRegion):Dynamic {
		return frameMapsIds.get(getID(region));
	}
	#end

	/**
	 * 获取渲染ID
	 * @param region
	 * @return Int
	 */
	@:keep
	public function getID(region:AtlasRegion):Int {
		return _ids.get(region);
	}

	// public function getWidth(region:AtlasRegion):Float {
	// 	return _widths.get(region);
	// }

	public function getRectByID(id:Int):Rectangle {
		return _tileset.getRect(id);
	}

	public function getTileset():Tileset {
		return _tileset;
	}

	public function unloadPage(page:AtlasPage):Void {
		_tileset.bitmapData.dispose();
		#if zygame
		frameMapsIds = null;
		frameMaps = null;
		#end
	}
}
