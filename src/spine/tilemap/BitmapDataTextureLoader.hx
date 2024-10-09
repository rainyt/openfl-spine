package spine.tilemap;

import spine.atlas.TextureAtlasPage;
import spine.atlas.TextureAtlasRegion;
#if zygame
import zygame.utils.load.Atlas;
import zygame.utils.load.Frame;
#end
import spine.atlas.TextureAtlas;
import spine.atlas.TextureLoader;
import openfl.display.BitmapData;
import openfl.display.Tileset;
import openfl.geom.Rectangle;
import zygame.utils.StringUtils;

@:keep
class BitmapDataTextureLoader implements TextureLoader {
	private var _bitmapData:Map<String, BitmapData>;

	private var _tileset:Tileset;

	#if zygame
	private var _atlas:Atlas;
	#end

	private var _atlasRegionMaps:Map<String, TextureAtlasRegion>;

	private var _ids:Map<TextureAtlasRegion, Int>;

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

	public function loadPage(page:TextureAtlasPage, path:String):Void {
		var bitmapData:BitmapData = this._bitmapData.get(StringUtils.getName(path));
		if (bitmapData == null)
			throw("BitmapData not found with name: " + path);
		_tileset = new Tileset(bitmapData);
		#if zygame
		_atlas = new Atlas(_tileset);
		#end
		_ids = new Map<TextureAtlasRegion, Int>();
		_atlasRegionMaps = [];
		// _widths = [];
		page.texture = this;
		page.width = bitmapData.width;
		page.height = bitmapData.height;
	}

	public function loadRegion(region:TextureAtlasRegion):Void {
		var rotate = region.degrees != 0;
		var regionWidth:Int = rotate ? region.height : region.width;
		var regionHeight:Int = rotate ? region.width : region.height;
		// _widths.set(region, region.width);
		_atlasRegionMaps.set(region.name, region);
		var rect = new Rectangle(region.x, region.y, regionWidth, regionHeight);
		var id:Int = _tileset.addRect(rect);
		_ids.set(region, id);
		if (!rotate) {
			region.width = region.originalWidth;
			region.height = region.originalHeight;
		} else {
			region.height = region.originalWidth;
			region.width = region.originalHeight;
		}
		#if zygame
		// 批渲染帧
		var frame = new Frame(_atlas);
		frame.x = rect.x;
		frame.y = rect.y;
		frame.width = rect.width;
		frame.height = rect.height;
		if (rotate) {
			frame.width = rect.height;
			frame.height = rect.width;
		}
		frame.name = region.name;
		frame.rotate = rotate;
		frame.id = id;
		frameMaps.set(region.name, frame);
		frameMapsIds.set(id, frame);
		#end
	}

	public function getRegionByName(name:String):TextureAtlasRegion {
		return _atlasRegionMaps.get(name);
	}

	#if zygame
	public function getFrameByRegion(region:TextureAtlasRegion):Dynamic {
		return frameMapsIds.get(getID(region));
	}
	#end

	/**
	 * 获取渲染ID
	 * @param region
	 * @return Int
	 */
	@:keep
	public function getID(region:TextureAtlasRegion):Int {
		return _ids.get(region);
	}

	public function getRectByID(id:Int):TextureAtlasRegion {
		// return _tileset.getRect(id);
		// TODO 这里丢失了类？
		return null;
	}

	public function getTileset():Tileset {
		return _tileset;
	}

	public function unloadPage(page:TextureAtlasPage):Void {
		_tileset.bitmapData.dispose();
		#if zygame
		frameMapsIds = null;
		frameMaps = null;
		#end
	}
}
