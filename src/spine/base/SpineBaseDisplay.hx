package spine.base;

interface SpineBaseDisplay {

    public var visible(get,set):Bool;

	public var isPlay(get, set):Bool;
    
    public function onSpineUpdate(dt:Float):Void;

}