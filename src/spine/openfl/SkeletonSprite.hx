/******************************************************************************
 * Spine Runtimes Software License
 * Version 2.1
 *
 * Copyright (c) 2013, Esoteric Software
 * All rights reserved.
 *
 * You are granted a perpetual, non-exclusive, non-sublicensable and
 * non-transferable license to install, execute and perform the Spine Runtimes
 * Software (the "Software") solely for internal use. Without the written
 * permission of Esoteric Software (typically granted by licensing Spine), you
 * may not (a) modify, translate, adapt or otherwise create derivative works,
 * improvements of the Software or develop new applications using the Software
 * or (b) remove, delete, alter or obscure any trademarks or any copyright,
 * trademark, patent or other intellectual property or proprietary rights
 * notices on or in the Software, including any copy thereof. Redistributions
 * in binary or source form must include this license and terms.
 *
 * THIS SOFTWARE IS PROVIDED BY ESOTERIC SOFTWARE "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 * EVENT SHALL ESOTERIC SOFTARE BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *****************************************************************************/

package spine.openfl;

import openfl.display.TriangleCulling;
import openfl.display.BitmapData;
import openfl.display.Sprite;
#if zygame
import zygame.display.DisplayObjectContainer;
#end
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.Vector;
import spine.attachments.MeshAttachment;

import spine.Bone;
import spine.Skeleton;
import spine.SkeletonData;
import spine.Slot;
import spine.support.graphics.TextureAtlas;
import spine.attachments.RegionAttachment;
import spine.support.graphics.Color;
import openfl.events.Event;

/**
 * Sprite渲染器
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

		this.graphics.clear();
		for (i in 0 ... n)
		{
			//获取骨骼
			slot = drawOrder[i];
			//初始化参数
			triangles = null;
			uvs = null;
			atlasRegion = null;
			bitmapData = null;
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
					bitmapData = cast atlasRegion.page.rendererObject;
					this.graphics.beginBitmapFill(bitmapData,null,true,true);
					this.graphics.drawTriangles(ofArrayFloat(_tempVerticesArray),ofArrayInt(triangles),ofArrayFloat(uvs),TriangleCulling.NONE);
					this.graphics.endFill();
				}

				
			}
		}
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
