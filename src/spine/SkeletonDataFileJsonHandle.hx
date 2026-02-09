#if !spine4_2
package spine;

import spine.support.utils.JsonValue;
import haxe.Json;
import spine.support.utils.JsonValue.JsonDynamic;

#if (spine_hx >= '3.8.2')
#if api_lang_en
/**
 * Skeleton data JSON file handle implementation
 * Requires rainyt/spine-hx 3.8 branch support from Github
 */
#else
/**
 * 骨骼数据JSON文件句柄实现
 * 需要使用Github中的rainyt/spine-hx 3.8分支支持
 */
#end
class SkeletonDataFileJsonHandle implements spine.support.files.JsonFileHandle {
	public var path:String = "";

	private var _data:Dynamic;

	#if api_lang_en
	/**
	 * Constructor
	 * @param path File path
	 * @param data Optional JSON data, if not provided it will be loaded from the path
	 */
	#else
	/**
	 * 构造函数
	 * @param path 文件路径
	 * @param data 可选的JSON数据，如果未提供则从路径加载
	 */
	#end
	public function new(path:String, data:Dynamic = null) {
		this.path = path;
		if (this.path == null)
			this.path = "";
		_data = data;
		if (_data == null)
			_data = Json.parse(openfl.Assets.getText(path));
	}

	#if api_lang_en
	/**
	 * Get file content
	 * @return JSON data as string
	 */
	#else
	/**
	 * 获取文件内容
	 * @return JSON数据字符串
	 */
	#end
	public function getContent():String {
		return _data;
	}

	#if api_lang_en
	/**
	 * Get JSON value
	 * @return JsonValue instance
	 */
	#else
	/**
	 * 获取JSON值
	 * @return JsonValue实例
	 */
	#end
	public function getJson():JsonValue {
		return new JsonDynamic(_data);
	}
}
#end
#end
