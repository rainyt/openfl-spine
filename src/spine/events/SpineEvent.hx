#if api_lang_en
/**
 * Spine event class
 * Extends OpenFL Event to handle Spine-specific events
 */
#else
/**
 * Spine事件类
 * 扩展OpenFL Event以处理Spine特定的事件
 */
#end
package spine.events;

#if spine4_2
import spine.animation.TrackEntry;
#else
import spine.AnimationState.AnimationStateListener;
import spine.AnimationState.TrackEntry;
#end
import spine.Event;
import openfl.events.EventDispatcher;
import openfl.events.Event in OpenFLEvent;

class SpineEvent extends OpenFLEvent {
	#if api_lang_en
	/**
	 * Dispatched when each action finishes playing
	 */
	#else
	/**
	 * 每个动作播放完成时调度
	 */
	#end
	inline public static var END:String = "end";

	#if api_lang_en
	/**
	 * Dispatched when animation finishes playing
	 */
	#else
	/**
	 * 当动画播放完成时调度
	 */
	#end
	inline public static var COMPLETE:String = "complete";

	#if api_lang_en
	/**
	 * Dispatched after instance is disposed
	 */
	#else
	/**
	 * 实例被释放后调度
	 */
	#end
	inline public static var DISPOSE:String = "dispose";

	#if api_lang_en
	/**
	 * Dispatched when animation is interrupted
	 */
	#else
	/**
	 * 当动画被中断时调度
	 */
	#end
	inline public static var INTERRUPT:String = "interrupt";

	#if api_lang_en
	/**
	 * Dispatched when animation starts playing
	 */
	#else
	/**
	 * 动画开始播放时调度
	 */
	#end
	inline public static var START:String = "start";

	#if api_lang_en
	/**
	 * Dispatched when custom event occurs
	 */
	#else
	/**
	 * 自定义事件发生时调度
	 */
	#end
	inline public static var EVENT:String = "event";

	#if api_lang_en
	/**
	 * Track entry associated with the event
	 */
	#else
	/**
	 * 与事件关联的轨道条目
	 */
	#end
	public var entry:TrackEntry;

	#if api_lang_en
	/**
	 * Original Spine event for event event handling
	 */
	#else
	/**
	 * event事件处理的原生Spine事件
	 */
	#end
	public var event:Event;
}
