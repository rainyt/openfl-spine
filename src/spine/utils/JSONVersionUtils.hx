#if !spine4_2
#if api_lang_en
/**
 * Spine JSON version compatibility utility
 * Handles version upgrades for Spine JSON data
 */
#else
/**
 * Spine的JSON版本上下兼容工具
 * 处理Spine JSON数据的版本升级
 */
#end
package spine.utils;

class JSONVersionUtils {
	#if api_lang_en
	/**
	 * Gets Spine object data as JSON string with version compatibility
	 * @param data Spine data object
	 * @return JSON string of Spine data
	 */
	#else
	/**
	 * 获取Spine对象数据的JSON字符串，处理版本兼容性
	 * @param data Spine数据对象
	 * @return Spine数据的JSON字符串
	 */
	#end
	public static function getSpineObjectData(data:Dynamic):String {
		#if spine38
		var spineversion:String = data.skeleton.spine;
		var array = spineversion.split(".");
		spineversion = array[0] + array[1];
		if (Std.parseInt(spineversion) <= 37) {
			// 版本为3.7.*版本，需要升级结构
			data.skeleton.spine = "3.8.99";
			var skins:Array<{name:String, attachments:Dynamic}> = [];
			var keys = Reflect.fields(data.skins);
			for (key in keys) {
				skins.push({
					name: key,
					attachments: Reflect.getProperty(data.skins, key)
				});
			}
			data.skins = skins;
		}
		#end
		return haxe.Json.stringify(data);
	}

	#if api_lang_en
	/**
	 * Gets Spine object JSON data
	 * @param data Spine data object
	 * @return Spine data object
	 */
	#else
	/**
	 * 获取Spine对象JSON数据
	 * @param data Spine数据对象
	 * @return Spine数据对象
	 */
	#end
	public static function getSpineObjectJsonData(data:Dynamic):Dynamic {
		// TODO 应该遵循Spine的所有版本，不进行兼容处理
		// #if spine38
		// var spineversion:String = data.skeleton.spine;
		// var array = spineversion.split(".");
		// spineversion = array[0] + array[1];
		// if (Std.parseInt(spineversion) <= 37) {
		// 	// 版本为3.7.*版本，需要升级结构
		// 	data.skeleton.spine = "3.8.99";
		// 	var skins:Array<{name:String, attachments:Dynamic}> = [];
		// 	var keys = Reflect.fields(data.skins);
		// 	for (key in keys) {
		// 		skins.push({
		// 			name: key,
		// 			attachments: Reflect.getProperty(data.skins, key)
		// 		});
		// 	}
		// 	data.skins = skins;
		// }
		// #end
		return data;
	}
}
#end