package spine.utils;

import openfl.Vector;

class VectorUtils {

    public static function pushVectorFloat(v:Vector<Float>,v2:Vector<Float>):Void
    {
        for(i in 0...v2.length)
            v.push(v2[i]);
    }

    public static function pushVectorInt(v:Vector<Int>,v2:Vector<Int>):Void
    {
        for(i in 0...v2.length)
            v.push(v2[i]);
    }

}