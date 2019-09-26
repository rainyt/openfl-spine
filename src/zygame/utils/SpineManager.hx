package zygame.utils;

import openfl.events.Event;
import openfl.display.Stage;
import spine.base.SpineBaseDisplay;

/**
 * 用于管理Spine的动画统一播放处理
 */
class SpineManager {

    private static var spineOnFrames:Array<SpineBaseDisplay> = [];

    private static var stage:Stage;

    /**
     * 初始化更新器
     * @param stage 
     */
    public static function init(pstage:Stage):Void
    {
        if(stage != null)
            return;
        stage = pstage;
        stage.addEventListener(Event.ENTER_FRAME,onFrame);
    }

    private static function onFrame(event:Event):Void
    {
        for (display in spineOnFrames) {
            display.onSpineUpdate();
        }
    }

    /**
     * 添加到更新器中
     * @param spine 
     */
    public static function addOnFrame(spine:SpineBaseDisplay):Void
    {   
        if(spineOnFrames.indexOf(spine) == -1)
            spineOnFrames.push(spine);
    }

    /**
     * 从更新器中移除
     * @param spine 
     */
    public static function removeOnFrame(spine:SpineBaseDisplay):Void
    {
        spineOnFrames.remove(spine);
    }

}