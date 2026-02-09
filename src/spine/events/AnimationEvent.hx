#if api_lang_en
/**
 * Animation event implementation
 * Dispatches Spine animation events to OpenFL event system
 */
#else
/**
 * 动画事件实现
 * 将Spine动画事件分发到OpenFL事件系统
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

class AnimationEvent extends EventDispatcher #if !spine4_2 implements AnimationStateListener #end {

    #if api_lang_en
    /**
     * Invoked when this entry has been set as the current entry
     * @param entry Track entry that was started
     */
    #else
    /**
     * 当此条目被设置为当前条目时调用
     * @param entry 已启动的轨道条目
     */
    #end
    public function start(entry:TrackEntry):Void
    {
        var event2:SpineEvent = new SpineEvent("start");
        event2.entry = entry;
        this.dispatchEvent(event2);
    }

    #if api_lang_en
    /**
     * Invoked when another entry has replaced this entry as the current entry
     * This entry may continue being applied for mixing
     * @param entry Track entry that was interrupted
     */
    #else
    /**
     * 当另一个条目替换此条目作为当前条目时调用
     * 此条目可能会继续应用于混合
     * @param entry 被中断的轨道条目
     */
    #end
    public function interrupt(entry:TrackEntry):Void{
        var event2:SpineEvent = new SpineEvent("interrupt");
        event2.entry = entry;
        this.dispatchEvent(event2);
    }

    #if api_lang_en
    /**
     * Invoked when this entry is no longer the current entry and will never be applied again
     * @param entry Track entry that ended
     */
    #else
    /**
     * 当此条目不再是当前条目且永远不会再被应用时调用
     * @param entry 已结束的轨道条目
     */
    #end
    public function end(entry:TrackEntry):Void{
        var event2:SpineEvent = new SpineEvent("end");
        event2.entry = entry;
        this.dispatchEvent(event2);
    }

    #if api_lang_en
    /**
     * Invoked when this entry will be disposed
     * This may occur without the entry ever being set as the current entry
     * References to the entry should not be kept after dispose is called
     * @param entry Track entry that will be disposed
     */
    #else
    /**
     * 当此条目将被销毁时调用
     * 这可能会在条目从未被设置为当前条目的情况下发生
     * 在调用dispose后不应保留对条目的引用
     * @param entry 将被销毁的轨道条目
     */
    #end
    public function dispose(entry:TrackEntry):Void{
        var event2:SpineEvent = new SpineEvent("dispose");
        event2.entry = entry;
        this.dispatchEvent(event2);
    }

    #if api_lang_en
    /**
     * Invoked every time this entry's animation completes a loop
     * @param entry Track entry whose animation completed a loop
     */
    #else
    /**
     * 每当此条目的动画完成一个循环时调用
     * @param entry 动画完成循环的轨道条目
     */
    #end
    public function complete(entry:TrackEntry):Void{
        var event2:SpineEvent = new SpineEvent("complete");
        event2.entry = entry;
        this.dispatchEvent(event2);
    }

    #if api_lang_en
    /**
     * Invoked when this entry's animation triggers an event
     * @param entry Track entry that triggered the event
     * @param event The event that was triggered
     */
    #else
    /**
     * 当此条目的动画触发事件时调用
     * @param entry 触发事件的轨道条目
     * @param event 被触发的事件
     */
    #end
    public function event(entry:TrackEntry, event:Event):Void{
        var event2:SpineEvent = new SpineEvent("event");
        event2.event = event;
        event2.entry = entry;
        this.dispatchEvent(event2);
    }

}
