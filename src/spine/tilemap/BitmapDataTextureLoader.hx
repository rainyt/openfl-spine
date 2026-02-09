package spine.tilemap;

#if zygame
import zygame.utils.load.Atlas;
import zygame.utils.load.Frame;
#end
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

	private var _atlasRegionMaps:Map<String, #if spine4_2 TextureAtlasRegion #else AtlasRegion #end>;

	private var _ids:Map< #if spine4_2 TextureAtlasRegion #else AtlasRegion #end, Int>;

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

	public function loadPage(page:#if spine4_2 TextureAtlasPage #else AtlasPage #end, path:String):Void {
		var bitmapData:BitmapData = this._bitmapData.get(StringUtils.getName(path));
		if (bitmapData == null)
			throw("BitmapData not found with name: " + path);
		_tileset = new Tileset(bitmapData);
		#if zygame
		_atlas = new Atlas(_tileset);
		#end
		_ids = new Map< #if spine4_2 TextureAtlasRegion #else AtlasRegion #end, Int>();
		_atlasRegionMaps = [];
		// _widths = [];
		#if spine4_2
		page.texture = this;
		#else
		page.rendererObject = this;
		#end

		page.width = bitmapData.width;
		page.height = bitmapData.height;
	}

	public function loadRegion(region:#if spine4_2 TextureAtlasRegion #else AtlasRegion #end):Void {
		#if spine4_2
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
		#else
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
		var frame = new Frame(_atlas);
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
		#end
	}

	public function getRegionByName(name:String):#if spine4_2 TextureAtlasRegion #else AtlasRegion #end {
		return _atlasRegionMaps.get(name);
	}

	#if zygame
	public function getFrameByRegion(region:#if spine4_2 TextureAtlasRegion #else AtlasRegion #end):Dynamic {
		return frameMapsIds.get(getID(region));
	}
	#end

	/**
	 * 获取渲染ID
	 * @param region
	 * @return Int
	 */
	@:keep
	public function getID(region:#if spine4_2 TextureAtlasRegion #else AtlasRegion #end):Int {
		return _ids.get(region);
	}

	#if spine4_2
	public function getRectByID(id:Int):TextureAtlasRegion {
		// return _tileset.getRect(id);
		// TODO 这里丢失了类？
		return null;
	}
	#else
	public function getRectByID(id:Int):Rectangle {
		return _tileset.getRect(id);
	}
	#end

	public function getTileset():Tileset {
		return _tileset;
	}

	public function unloadPage(page:#if spine4_2 TextureAtlasPage #else AtlasPage #end):Void {
		_tileset.bitmapData.dispose();
		#if zygame
		frameMapsIds = null;
		frameMaps = null;
		#end
	}
}
