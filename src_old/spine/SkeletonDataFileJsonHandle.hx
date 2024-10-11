package spine;

import spine.support.utils.JsonValue;
import haxe.Json;
import spine.support.utils.JsonValue.JsonDynamic;

#if (spine_hx>='3.8.2')
/**
 * 需要使用Github中的rainyt/spine-hx 3.8分支支持
 */
class SkeletonDataFileJsonHandle implements spine.support.files.JsonFileHandle {
	public var path:String = "";

	private var _data:Dynamic;

	public function new(path:String, data:Dynamic = null) {
		this.path = path;
		if (this.path == null)
			this.path = "";
		_data = data;
		if (_data == null)
			_data = Json.parse(openfl.Assets.getText(path));
	}

	public function getContent():String {
		return _data;
	}

	public function getJson():JsonValue {
		return new JsonDynamic(_data);
	}
}
#end