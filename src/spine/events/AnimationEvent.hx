package spine.events;

import spine.AnimationState.AnimationStateListener;
import spine.AnimationState.TrackEntry;
import spine.Event;
import openfl.events.EventDispatcher;
import openfl.events.Event in OpenFLEvent;

/**
 * 动画事件实现
 */
class AnimationEvent extends EventDispatcher implements AnimationStateListener{

    /** Invoked when this entry has been set as the current entry. */
    public function start(entry:TrackEntry):Void
    {
        var event2:SpineEvent = new SpineEvent("start");
        event2.entry = entry;
        this.dispatchEvent(event2);
    }

    /** Invoked when another entry has replaced this entry as the current entry. This entry may continue being applied for
     * mixing. */
    public function interrupt(entry:TrackEntry):Void{
        var event2:SpineEvent = new SpineEvent("interrupt");
        event2.entry = entry;
        this.dispatchEvent(event2);
    }

    /** Invoked when this entry is no longer the current entry and will never be applied again. */
    public function end(entry:TrackEntry):Void{
        var event2:SpineEvent = new SpineEvent("end");
        event2.entry = entry;
        this.dispatchEvent(event2);
    }

    /** Invoked when this entry will be disposed. This may occur without the entry ever being set as the current entry.
     * References to the entry should not be kept after <code>dispose</code> is called, as it may be destroyed or reused. */
    public function dispose(entry:TrackEntry):Void{
        var event2:SpineEvent = new SpineEvent("dispose");
        event2.entry = entry;
        this.dispatchEvent(event2);
    }

    /** Invoked every time this entry's animation completes a loop. */
    public function complete(entry:TrackEntry):Void{
        var event2:SpineEvent = new SpineEvent("complete");
        event2.entry = entry;
        this.dispatchEvent(event2);
    }

    /** Invoked when this entry's animation triggers an event. */
    public function event(entry:TrackEntry, event:Event):Void{
        var event2:SpineEvent = new SpineEvent("event");
        event2.event = event;
        event2.entry = entry;
        this.dispatchEvent(event2);
    }

}
