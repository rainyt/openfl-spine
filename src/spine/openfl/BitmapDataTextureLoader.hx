#if api_lang_en
/**
 * BitmapData texture loader implementation
 * Loads textures from BitmapData objects for Spine atlas
 */
#else
/**
 * BitmapData纹理加载器实现
 * 从BitmapData对象加载Spine图集的纹理
 */
#end
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
	#if api_lang_en
	/**
	 * Map of BitmapData objects by name
	 */
	#else
	/**
	 * 按名称存储的BitmapData对象映射
	 */
	#end
	private var _bitmapData:Map<String, BitmapData>;

	#if api_lang_en
	/**
	 * Map of atlas regions by name
	 */
	#else
	/**
	 * 按名称存储的图集区域映射
	 */
	#end
	private var _regions:Map<String, #if spine4_2 TextureAtlasRegion #else AtlasRegion #end> = [];

	#if api_lang_en
	/**
	 * Creates a new BitmapDataTextureLoader
	 * @param bitmapData Map of BitmapData objects to use for textures
	 */
	#else
	/**
	 * 创建一个新的BitmapDataTextureLoader
	 * @param bitmapData 用于纹理的BitmapData对象映射
	 */
	#end
	public function new(bitmapData:Map<String, BitmapData>) {
		this._bitmapData = bitmapData;
	}

	#if api_lang_en
	/**
	 * Loads a texture page from BitmapData
	 * @param page Texture atlas page to load
	 * @param path Path to the texture
	 */
	#else
	/**
	 * 从BitmapData加载纹理页面
	 * @param page 要加载的纹理图集页面
	 * @param path 纹理的路径
	 */
	#end
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

	#if api_lang_en
	/**
	 * Gets an atlas region by name
	 * @param name Name of the region to get
	 * @return The atlas region if found, null otherwise
	 */
	#else
	/**
	 * 按名称获取图集区域
	 * @param name 要获取的区域名称
	 * @return 如果找到则返回图集区域，否则返回null
	 */
	#end
	public function getRegionByName(name:String):#if spine4_2 TextureAtlasRegion #else AtlasRegion #end {
		return _regions.get(name);
	}

	#if api_lang_en
	/**
	 * Loads an atlas region
	 * @param region Atlas region to load
	 */
	#else
	/**
	 * 加载图集区域
	 * @param region 要加载的图集区域
	 */
	#end
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
		#if !spine4_2
		page.rendererObject.dispose();
		#else
		page.texture.dispose();
		#end
	}
}
