package spine.openfl;

import openfl.Vector;

/**
 * Spine的动画数据缓存
 */
class SpineCacheData {
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
	
	public var allTrianglesBlendModeType:Array<Float>;

	/**
	 * 三角形颜色运算
	 */
	public var allTrianglesColor:Array<Float>;
	
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

	public function new() {}
}
