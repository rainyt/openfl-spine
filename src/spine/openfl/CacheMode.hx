#if api_lang_en
/**
 * Cache mode enumeration
 * Defines different cache modes for Spine rendering
 */
#else
/**
 * 缓存模式枚举
 * 定义Spine渲染的不同缓存模式
 */
#end
package spine.openfl;

#if !spine4_2
enum CacheMode {
	#if api_lang_en
	/**
	 * Triangle data cache mode
	 */
	#else
	/**
	 * 三角形数据缓存模式
	 */
	#end
	TRIANGLES;
	#if api_lang_en
	/**
	 * Shape data cache mode
	 */
	#else
	/**
	 * 图形数据缓存模式
	 */
	#end
	SHAPE;
}
#end
