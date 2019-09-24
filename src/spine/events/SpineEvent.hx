package spine.events;

import spine.AnimationState.AnimationStateListener;
import spine.AnimationState.TrackEntry;
import spine.Event;
import openfl.events.EventDispatcher;
import openfl.events.Event in OpenFLEvent;

/**
 * Spine事件处理
 */
class SpineEvent extends OpenFLEvent
{

    /**
     * 每个动作播放完成时
     */
    public static var END:String = "end";   

    /**
     * 当动画播放完成时
     */
    public static var COMPLETE:String = "complete";

    /**
     * 实例被释放后
     */
    public static var DISPOSE:String = "dispose";

    public static var INTERRUPT:String = "interrupt";

    /**
     * 动画开始播放时
     */
    public static var START:String = "start";

    /**
     * 自定义事件发生时
     */
    public static var EVENT:String = "event";

    /**
     * 
     */
    public var entry:TrackEntry;

    /**
     * event事件处理的原生Spine事件
     */
    public var event:Event;

}