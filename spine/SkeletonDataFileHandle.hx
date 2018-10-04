package spine;

class SkeletonDataFileHandle implements spine.support.files.FileHandle {

	public var path:String = "";

	private var _data:String;

	public function new(path:String,data:String = null){
		this.path = path;
		if(this.path == null)
			this.path = "";
		_data = data;
		if(_data == null)
			_data = openfl.Assets.getText(path);
	}

	public function getContent():String{
		return _data;
	}

}