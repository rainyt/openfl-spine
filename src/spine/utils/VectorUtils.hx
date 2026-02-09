#if api_lang_en
/**
 * Vector utility class for Spine
 * Provides helper methods for vector operations
 */
#else
/**
 * Spine的向量工具类
 * 提供向量操作的辅助方法
 */
#end
package spine.utils;

import openfl.Vector;

class VectorUtils {
	#if api_lang_en
	/**
	 * Pushes all elements from one Float vector to another
	 * @param v Target vector
	 * @param v2 Source vector
	 */
	#else
	/**
	 * 将一个Float向量中的所有元素添加到另一个Float向量中
	 * @param v 目标向量
	 * @param v2 源向量
	 */
	#end
	public static function pushVectorFloat(v:Vector<Float>, v2:Vector<Float>):Void {
		for (i in 0...v2.length)
			v.push(v2[i]);
	}

	#if api_lang_en
	/**
	 * Pushes all elements from one Int vector to another
	 * @param v Target vector
	 * @param v2 Source vector
	 */
	#else
	/**
	 * 将一个Int向量中的所有元素添加到另一个Int向量中
	 * @param v 目标向量
	 * @param v2 源向量
	 */
	#end
	public static function pushVectorInt(v:Vector<Int>, v2:Vector<Int>):Void {
		for (i in 0...v2.length)
			v.push(v2[i]);
	}
}
