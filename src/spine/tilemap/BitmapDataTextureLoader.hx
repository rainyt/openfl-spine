#if api_lang_en
/**
 * Texture loader that uses BitmapData for tilemap rendering
 * Implements TextureLoader interface for Spine atlas loading
 */
#else
/**
 * 使用BitmapData的纹理加载器，用于瓦片渲染
 * 实现TextureLoader接口用于Spine图集加载
 */
#end
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
	#if api_lang_en
	/**
	 * Map of bitmap data by name
	 */
	#else
	/**
	 * 按名称存储的BitmapData映射
	 */
	#end
	private var _bitmapData:Map<String, BitmapData>;

	#if api_lang_en
	/**
	 * Tileset used for rendering
	 */
	#else
	/**
	 * 用于渲染的瓦片集
	 */
	#end
	private var _tileset:Tileset;

	#if zygame
	#if api_lang_en
	/**
	 * Atlas used for zygame batch rendering
	 */
	#else
	/**
	 * 用于zygame批渲染的图集
	 */
	#end
	private var _atlas:Atlas;
	#end

	#if api_lang_en
	/**
	 * Map of atlas regions by name
	 */
	#else
	/**
	 * 按名称存储的图集区域映射
	 */
	#end
	private var _atlasRegionMaps:Map<String, #if spine4_2 TextureAtlasRegion #else AtlasRegion #end>;

	#if api_lang_en
	/**
	 * Map of region to render ID
	 */
	#else
	/**
	 * 区域到渲染ID的映射
	 */
	#end
	private var _ids:Map< #if spine4_2 TextureAtlasRegion #else AtlasRegion #end, Int>;

	#if zygame
	#if api_lang_en
	/**
	 * Frame maps for batch rendering
	 */
	#else
	/**
	 * 可用于批渲染使用的图集内容
	 */
	#end
	public var frameMaps:Map<String, Frame> = [];

	#if api_lang_en
	/**
	 * Frame maps by ID for batch rendering
	 */
	#else
	/**
	 * 按ID存储的帧映射，用于批渲染
	 */
	#end
	public var frameMapsIds:Map<Int, Frame> = [];
	#end

	#if api_lang_en
	/**
	 * Creates a new BitmapDataTextureLoader
	 * @param bitmapDatas Map of bitmap data by name
	 */
	#else
	/**
	 * 创建一个新的BitmapDataTextureLoader
	 * @param bitmapDatas 按名称存储的BitmapData映射
	 */
	#end
	public function new(bitmapDatas:Map<String, BitmapData>) {
		this._bitmapData = bitmapDatas;
	}

	#if api_lang_en
	/**
	 * Loads a texture page
	 * @param page Texture atlas page to load
	 * @param path Path to the texture
	 */
	#else
	/**
	 * 加载纹理页面
	 * @param page 要加载的纹理图集页面
	 * @param path 纹理路径
	 */
	#end
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

	#if api_lang_en
	/**
	 * Loads a texture region
	 * @param region Texture atlas region to load
	 */
	#else
	/**
	 * 加载纹理区域
	 * @param region 要加载的纹理图集区域
	 */
	#end
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

	#if api_lang_en
	/**
	 * Gets a region by name
	 * @param name Region name
	 * @return Texture atlas region
	 */
	#else
	/**
	 * 根据名称获取区域
	 * @param name 区域名称
	 * @return 纹理图集区域
	 */
	#end
	public function getRegionByName(name:String):#if spine4_2 TextureAtlasRegion #else AtlasRegion #end {
		return _atlasRegionMaps.get(name);
	}

	#if zygame
	#if api_lang_en
	/**
	 * Gets a frame by region for batch rendering
	 * @param region Texture atlas region
	 * @return Frame for batch rendering
	 */
	#else
	/**
	 * 根据区域获取批渲染使用的帧
	 * @param region 纹理图集区域
	 * @return 批渲染使用的帧
	 */
	#end
	public function getFrameByRegion(region:#if spine4_2 TextureAtlasRegion #else AtlasRegion #end):Dynamic {
		return frameMapsIds.get(getID(region));
	}
	#end

	#if api_lang_en
	/**
	 * Gets render ID for a region
	 * @param region Texture atlas region
	 * @return Render ID
	 */
	#else
	/**
	 * 获取渲染ID
	 * @param region 纹理图集区域
	 * @return 渲染ID
	 */
	#end
	@:keep
	public function getID(region:#if spine4_2 TextureAtlasRegion #else AtlasRegion #end):Int {
		return _ids.get(region);
	}

	#if api_lang_en
	/**
	 * Gets region by ID (spine4.2+)
	 * @param id Render ID
	 * @return Texture atlas region
	 */
	#else
	/**
	 * 根据ID获取区域 (spine4.2+)
	 * @param id 渲染ID
	 * @return 纹理图集区域
	 */
	#end
	#if spine4_2
	public function getRectByID(id:Int):TextureAtlasRegion {
		// return _tileset.getRect(id);
		// TODO 这里丢失了类？
		return null;
	}
	#else
	#if api_lang_en
	/**
	 * Gets rectangle by ID
	 * @param id Render ID
	 * @return Rectangle
	 */
	#else
	/**
	 * 根据ID获取矩形
	 * @param id 渲染ID
	 * @return 矩形
	 */
	#end
	public function getRectByID(id:Int):Rectangle {
		return _tileset.getRect(id);
	}
	#end

	#if api_lang_en
	/**
	 * Gets the tileset
	 * @return Tileset
	 */
	#else
	/**
	 * 获取瓦片集
	 * @return 瓦片集
	 */
	#end
	public function getTileset():Tileset {
		return _tileset;
	}

	#if api_lang_en
	/**
	 * Unloads a texture page
	 * @param page Texture atlas page to unload
	 */
	#else
	/**
	 * 卸载纹理页面
	 * @param page 要卸载的纹理图集页面
	 */
	#end
	public function unloadPage(page:#if spine4_2 TextureAtlasPage #else AtlasPage #end):Void {
		_tileset.bitmapData.dispose();
		#if zygame
		frameMapsIds = null;
		frameMaps = null;
		#end
	}
}
