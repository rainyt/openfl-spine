#if !spine4_2
package spine;

#if api_lang_en
/**
 * Skeleton data file handle implementation
 */
#else
/**
 * 骨骼数据文件句柄实现
 */
#end
class SkeletonDataFileHandle implements spine.support.files.FileHandle {
	public var path:String = "";

	private var _data:String;

	#if api_lang_en
	/**
	 * Constructor
	 * @param path File path
	 * @param data Optional file content, if not provided it will be loaded from the path
	 */
	#else
	/**
	 * 构造函数
	 * @param path 文件路径
	 * @param data 可选的文件内容，如果未提供则从路径加载
	 */
	#end
	public function new(path:String, data:String = null) {
		this.path = path;
		if (this.path == null)
			this.path = "";
		_data = data;
		if (_data == null)
			_data = openfl.Assets.getText(path);
	}

	#if api_lang_en
	/**
	 * Get file content
	 * @return File content as string
	 */
	#else
	/**
	 * 获取文件内容
	 * @return 文件内容字符串
	 */
	#end
	public function getContent():String {
		return _data;
	}
}
#end
