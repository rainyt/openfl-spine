package spine.base;

interface SpineBaseDisplay {
	/**
	 * 是否可见
	 */
	public var visible(get, set):Bool;

	/**
	 * 是否正在播放
	 */
	public var isPlay(get, set):Bool;

	/**
	 * 是否不可见
	 * @return Bool
	 */
	public function isHidden():Bool;

	/**
	 * Spine渲染
	 * @param dt 
	 */
	public function onSpineUpdate(dt:Float):Void;

	/**
	 * 是否为独立运行，不受SpineManager的影响
	 */
	public var independent:Bool;

	/**
	 * 最后绘制时间
	 */
	public var lastDrawTime:Float;

	#if zygame
	public var customData:Dynamic;
	#end
}
