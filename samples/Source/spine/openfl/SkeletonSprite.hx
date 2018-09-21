package spine.openfl;

import openfl.display.TriangleCulling;
import openfl.display.BitmapData;
import openfl.display.Sprite;
#if zygame
import zygame.display.DisplayObjectContainer;
#end
import openfl.Vector;
import spine.attachments.MeshAttachment;

import spine.Skeleton;
import spine.SkeletonData;
import spine.Slot;
import spine.support.graphics.TextureAtlas;
import spine.attachments.RegionAttachment;
import spine.support.graphics.Color;
import openfl.events.Event;

/**
 * Sprite渲染器，单个Sprite会进行单次渲染
 */
class SkeletonSprite extends #if !zygame Sprite #else DisplayObjectContainer #end {

	public var skeleton:Skeleton;
	public var timeScale:Float = 1;


	//坐标数组
	private var _tempVerticesArray:Array<Float>;
	//矩形三角形
	private var _quadTriangles:Array<Int>;
	//颜色数组（未实现）
	private var _colors:Array<Int>;
	//是否正在播放
	private var _isPlay:Bool = true;

	/**
	 * 创建一个Spine对象
	 * @param skeletonData 骨骼数据 
	 */
	public function new(skeletonData:SkeletonData) {
		super();
		
		skeleton = new Skeleton(skeletonData);
		skeleton.updateWorldTransform();

		_tempVerticesArray = new Array<Float>();
		_quadTriangles = new Array<Int>();
		_quadTriangles[0] = 0;
		_quadTriangles[1] = 1;
		_quadTriangles[2] = 2;
		_quadTriangles[3] = 2;
		_quadTriangles[4] = 3;
		_quadTriangles[5] = 0;
		_colors = new Array<Int>();
		#if zygame
		this.setFrameEvent(true);
		#else
		this.addEventListener(Event.ENTER_FRAME, enterFrame);
		#end
	}

	#if zygame
	override public function onFrame():Void{
		advanceTime(1/60);
	}
	#else
	/**
	 * 渲染事件
	 * @param e 
	 */
	private function enterFrame(e:Event):Void
	{
		advanceTime(1/60);
	}
	#end

	/**
	 * 丢弃
	 */
	public function destroy():Void {
		#if zygame
		this.setFrameEvent(false);
		#else
		removeEventListener(Event.ENTER_FRAME, enterFrame);
		#end
		removeChildren();
		graphics.clear();
	}
	
	/**
	 * 播放
	 */
	public function play():Void {
		#if !zygame
		if (!hasEventListener(Event.ENTER_FRAME)) {
			addEventListener(Event.ENTER_FRAME, enterFrame);
		}
		#end
		_isPlay = true;
	}

	/**
	 * 停止
	 */
	public function stop():Void {
		#if !zygame
		if (hasEventListener(Event.ENTER_FRAME)) {
			removeEventListener(Event.ENTER_FRAME, enterFrame);
		}
		#end
		_isPlay = false;
	}

	/**
	 * 激活渲染
	 * @param delta 
	 */
	public function advanceTime (delta:Float):Void {
		if(_isPlay == false)
			return;
		skeleton.update(delta * timeScale);
		renderTriangles();
	}

	/**
	 * 渲染实现
	 */
	private function renderTriangles():Void
	{
		var drawOrder:Array<Slot> = skeleton.drawOrder;
		var n:Int = drawOrder.length;
		var triangles:Array<Int> = null;
		var uvs:Array<Float> = null;
		var verticesLength:Int = 0;
		var atlasRegion:AtlasRegion;
		var slot:Slot;
		var r:Float = 0, g:Float = 0, b:Float = 0, a:Float = 0;
		var color:Int;
		var blend:Int;
		var bitmapData:BitmapData = null;

		var allVerticesArray:Vector<Float> = new Vector<Float>();
		var allTriangles:Vector<Int> = new Vector<Int>();
		var allUvs:Vector<Float> = new Vector<Float>();

		this.graphics.clear();

		var t:Int = 0;

		for (i in 0 ... n)
		{
			//获取骨骼
			slot = drawOrder[i];
			//初始化参数
			triangles = null;
			uvs = null;
			atlasRegion = null;
			_tempVerticesArray.splice(0,_tempVerticesArray.length);
			//如果骨骼的渲染物件存在
			if(slot.attachment != null)
			{
				// trace("存在骨骼");
				if (Std.is(slot.attachment, RegionAttachment))
				{
					//如果是矩形
					var region:RegionAttachment = cast slot.attachment;
					verticesLength = 8;
					region.computeWorldVertices(slot.bone, _tempVerticesArray, 0, 2);
					uvs = region.getUVs();
					triangles = _quadTriangles;
					atlasRegion = cast region.getRegion();
					r = region.getColor().r;
					g = region.getColor().g;
					b = region.getColor().b;
					a = region.getColor().a;

				}
				else if(Std.is(slot.attachment, MeshAttachment)){
					//如果是网格
					var region:MeshAttachment = cast slot.attachment;
					verticesLength = 8;
					region.computeWorldVertices(slot,0,region.getWorldVerticesLength(), _tempVerticesArray,0,2);
					uvs = region.getUVs();
					triangles = region.getTriangles();
					atlasRegion = cast region.getRegion();
					r = region.getColor().r;
					g = region.getColor().g;
					b = region.getColor().b;
					a = region.getColor().a;
				}

				//矩形绘制
				if(atlasRegion != null)
				{
					if(bitmapData != atlasRegion.page.rendererObject)
					{
						bitmapData = cast atlasRegion.page.rendererObject;
						this.graphics.beginBitmapFill(bitmapData,null,true,true);
					}

					//顶点重新计算
					var v:Vector<Int> = ofArrayInt(triangles);
					for(vi in 0...v.length)
					{
						v[vi] += t;
					}
					t += Std.int(_tempVerticesArray.length/2);

					allVerticesArray = allVerticesArray.concat(ofArrayFloat(_tempVerticesArray));
					allTriangles = allTriangles.concat(v);
					allUvs = allUvs.concat(ofArrayFloat(uvs));
				}
				
			}
		}
		
		//实现一次性绘制
		this.graphics.drawTriangles(allVerticesArray,allTriangles,allUvs,TriangleCulling.NONE);
		this.graphics.endFill();
		
	}

	/**
	 * 渲染数组转换
	 * @param data 
	 * @return Vector<Int>
	 */
	private function ofArrayInt(data:Array<Int>):Vector<Int>
	{
		var v:Vector<Int> = new Vector<Int>();
		for(i in 0...data.length)
			v.set(i,data[i]);
		return v;
	}

	/**
	 * 渲染数组转换
	 * @param data 
	 * @return Vector<Float>
	 */
	private function ofArrayFloat(data:Array<Float>):Vector<Float>
	{
		var v:Vector<Float> = new Vector<Float>();
		for(i in 0...data.length)
			v.set(i,data[i]);
		return v;
	}

}
