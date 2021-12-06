package spine.openfl;

/**
 * 所有动画的缓存管理器，当前只影响SpineSprite的动画缓存
 */
class GlobalAnimationCache {
	private static var cacheMaps:Map<String, SpineCacheData> = [];

	/**
	 * 初始化缓存
	 */
	public static function init():Void {}

	/**
	 * 获取对应ID的缓存器
	 * @param id 
	 * @return SpineCacheData
	 */
	public static function getCacheByID(id:String):SpineCacheData {
		if (!cacheMaps.exists(id))
			cacheMaps.set(id, new SpineCacheData());
		return cacheMaps.get(id);
	}

	public static function clearCacheByID(id:String):Void {
		if (cacheMaps.exists(id)) {
			var cacheData = cacheMaps.get(id);
			#if zygame
			if (cacheData.glBitmapData != null) {
				cacheData.glBitmapData.dispose();
			}
			#end
			cacheMaps.remove(id);
		}
	}
}
