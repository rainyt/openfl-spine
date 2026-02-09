#if api_lang_en
/**
 * Spine base display interface
 * Defines the basic methods and properties for Spine display objects
 */
#else
/**
 * Spine基础显示接口
 * 定义了Spine显示对象的基本方法和属性
 */
#end
package spine.base;

interface SpineBaseDisplay {
	#if api_lang_en
	/**
	 * Whether the display is visible
	 */
	#else
	/**
	 * 是否可见
	 */
	#end
	public var visible(get, set):Bool;

	#if api_lang_en
	/**
	 * Whether the animation is playing
	 */
	#else
	/**
	 * 是否正在播放
	 */
	#end
	public var isPlay(get, set):Bool;

	#if api_lang_en
	/**
	 * Check if the display is hidden
	 * @return Bool Returns true if the display is hidden
	 */
	#else
	/**
	 * 是否不可见
	 * @return Bool 如果显示对象不可见则返回true
	 */
	#end
	public function isHidden():Bool;

	#if api_lang_en
	/**
	 * Update the Spine display
	 * @param dt Delta time for animation update
	 */
	#else
	/**
	 * Spine渲染更新
	 * @param dt 动画更新的时间增量
	 */
	#end
	public function onSpineUpdate(dt:Float):Void;

	#if api_lang_en
	/**
	 * Whether to run independently, not affected by SpineManager
	 */
	#else
	/**
	 * 是否为独立运行，不受SpineManager的影响
	 */
	#end
	public var independent:Bool;

	#if api_lang_en
	/**
	 * Last draw time
	 */
	#else
	/**
	 * 最后绘制时间
	 */
	#end
	public var lastDrawTime:Float;

	#if zygame
	#if api_lang_en
	/**
	 * Custom data for extended functionality
	 */
	#else
	/**
	 * 自定义数据，用于扩展功能
	 */
	#end
	public var customData:Dynamic;
	#end
}
