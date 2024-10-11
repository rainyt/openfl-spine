package spine.openfl;

import openfl.display.Sprite;
import openfl.display.Shape;
import openfl.Vector;

/**
 * Spine的动画数据缓存
 */
class SpineCacheData {
	/**
	 * 已缓存的精灵数据
	 */
	private var _cache:Map<String, Array<SpineCacheFrameData>> = [];

	public function new() {}

	/**
	 * 获取帧缓存
	 * @param anmieName 
	 * @param frame 
	 * @return Bool
	 */
	public function getFrame(anmieName:String, frame:Int):SpineCacheFrameData {
		if (!_cache.exists(anmieName))
			return null;
		return _cache.get(anmieName)[frame];
	}

	/**
	 * 添加指定的帧缓存
	 * @param anmieName 
	 * @param frame 
	 * @param data 
	 */
	public function addFrame(anmieName:String, frame:Int, data:SpineCacheFrameData) {
		if (!_cache.exists(anmieName))
			_cache.set(anmieName, []);
		_cache.get(anmieName)[frame] = data;
	}
}

class SpineCacheFrameData {
	/**
	 * 三角形透明参数
	 */
	public var allTrianglesAlpha:Array<Float>;

	/**
	 * 三角形BlendMode运算
	 */
	public var allTrianglesBlendMode:Array<Float>;

	/**
	 * 三角形颜色运算
	 */
	public var allTrianglesColor:Array<Float>;

	/**
	 * 深色颜色运算
	 */
	public var allTrianglesDarkColor:Array<Float>;

	/**
	 * 顶点坐标
	 */
	public var allVerticesArray:Vector<Float>;

	/**
	 * 顶点
	 */
	public var allTriangles:Vector<Int>;

	/**
	 * UV
	 */
	public var allUvs:Vector<Float>;

	/**
	 * 缓存图形
	 */
	public var shape:Shape;

	public function new() {}
}
