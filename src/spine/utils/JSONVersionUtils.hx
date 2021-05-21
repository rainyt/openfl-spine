package spine.utils;

/**
 * Spine的JSON版本上下兼容工具
 */
class JSONVersionUtils {
    
    public static function getSpineObjectData(data:Dynamic):String{
        #if spine38
        var spineversion:String = data.skeleton.spine;
        var array = spineversion.split(".");
        spineversion = array[0] + array[1];
        if(Std.parseInt(spineversion) <= 37){
            //版本为3.7.*版本，需要升级结构
            data.skeleton.spine = "3.8.99";
            var skins:Array<{name:String,attachments:Dynamic}> = [];
            var keys = Reflect.fields(data.skins);
            for (key in keys) {
                skins.push({
                    name: key,
                    attachments: Reflect.getProperty(data.skins,key)
                });
            }
            data.skins = skins;
        }
        #end
        return haxe.Json.stringify(data);
    }

}