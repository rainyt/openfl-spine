#if !zygame
package zygame.utils;

/**
 *  字符串工具
 */
class StringUtils {

    /**
     *  获取字符串的扩展名，如果不存在扩展名，则会返回null
     *  @param data - 
     *  @return String
     */
    public static function getExtType(data:String):String
    {
        if(data == null)
            return data;
        var index:Int = data.lastIndexOf(".");
        return index == -1?null:data.substr(index + 1);
    }

    /**
     *  获取字符串的名字，不带路径、扩展名
     *  @param data - 
     *  @return String
     */
    public static function getName(data:String):String
    {
        if(data == null)
            return data;
        data = data.substr(data.lastIndexOf("/")+1);
        data = data.substr(0,data.lastIndexOf("."));
        return data;
    }

}
#end