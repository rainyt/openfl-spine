package spine.openfl;

import spine.base.SpineBaseDisplay;
import openfl.display.Sprite;
import openfl.Vector;
import openfl.display.DisplayObject;
import spine.openfl.SkeletonSprite;
import openfl.events.Event;
import openfl.display.TriangleCulling;
import openfl.display.BitmapData;
import spine.utils.VectorUtils;
import zygame.utils.SpineManager;

/**
 * 骨骼批渲染处理
 */
class SkeletonBatchs extends Sprite implements SpineBaseDisplay{

    public var allVerticesArray:Vector<Float> = new Vector<Float>();
	public	var allTriangles:Vector<Int> = new Vector<Int>();
	public	var allUvs:Vector<Float> = new Vector<Float>();
    private var _bitmapData:BitmapData;
    private var _buffdataPoint:Int = 0;
    private var _uindex:Int = 0;
    private var _setXBool:Bool = true;
    private var _isClearTriangles:Bool = true;

    public function new(bitmapData:BitmapData){
        super();
        _bitmapData = bitmapData;
        SpineManager.addOnFrame(this);
    }

    public function onSpineUpdate(dt:Float):Void
    {
        this.graphics.clear();
        allVerticesArray.splice(0,allVerticesArray.length);
        allUvs.splice(0,allUvs.length);
        _buffdataPoint = 0;
        _uindex = 0;
        var ren:Int = this.numChildren;
        for(i in 0...ren)
        {
            var s:SkeletonSprite = cast this.getChildAt(i);
            s.advanceTime(dt);
        }
        endFill();
    }

    public function clearTriangles():Void
    {
        allTriangles.splice(0,allTriangles.length);
    }

    /**
     * 上传数据渲染
     * @param v 
     * @param i 
     * @param m 
     */
    public function uploadBuffData(sprite:SkeletonSprite, v:Vector<Float>,i:Vector<Int>,uvs:Vector<Float>):Void
    {
        var t:Int = Std.int(allUvs.length/2);
        if(true)
        {
            //顶点重新计算
            for(vi in 0...i.length)
            {
                i[vi] += t;
                //追加顶点
                allTriangles[_buffdataPoint] = i[vi];
                _buffdataPoint++;
            }
        }
        
        for(ui in 0...uvs.length)
        {
            //追加坐标
            allVerticesArray[_uindex] = v[ui] * (_setXBool?sprite.scaleX:sprite.scaleY);
            allVerticesArray[_uindex] += (_setXBool?sprite.x:sprite.y);
            //追加UV
            allUvs[_uindex] = uvs[ui];
            _uindex++;
            _setXBool = !_setXBool;
        }
        t += Std.int(uvs.length/2);
    }

    /**
     * 最终批渲染
     */
    private function endFill():Void
    {
        this.graphics.beginBitmapFill(_bitmapData,null,true,true);
        this.graphics.drawTriangles(allVerticesArray,allTriangles,allUvs,TriangleCulling.NONE);
        this.graphics.endFill();
        _isClearTriangles = false;
    }

    /**
     * 方法重写
     * @param child 
     * @param index 
     * @return DisplayObject
     */
    override public function addChildAt(child:DisplayObject,index:Int):DisplayObject
    {
        if(!Std.is(child,SkeletonSprite)){
            throw "请不要添加非spine.openfl.SkeletonSprite对象！";
        }
        var s:SkeletonSprite = cast(child,SkeletonSprite);
        s.batchs = this;
        s.graphics.clear();
        return super.addChildAt(child,index);
    }

}