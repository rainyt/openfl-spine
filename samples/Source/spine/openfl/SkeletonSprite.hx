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
import openfl.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.Vector;
import spine.attachments.MeshAttachment;

import spine.Bone;
import spine.Skeleton;
import spine.SkeletonData;
import spine.Slot;
import spine.support.graphics.TextureAtlas;
import spine.attachments.RegionAttachment;
import spine.support.graphics.Color;

class SkeletonSprite extends Sprite {
	static var tempPoint:Point = new Point();
	static var tempMatrix:Matrix = new Matrix();

	public var skeleton:Skeleton;
	public var timeScale:Float = 1;
	var lastTime:Int = 0;

	public var renderMeshes(default, set):Bool;

	var _tempVerticesArray:Array<Float>;
	var _quadTriangles:Array<Int>;
	var _colors:Array<Int>;

	// private var _map:Map<AtlasRegion,TileContainer>;



	public function new(skeletonData:SkeletonData, renderMeshes:Bool = false) {
		super();

		
		Bone.yDown = true;

		skeleton = new Skeleton(skeletonData);
		skeleton.updateWorldTransform();

		// _map = new Map<AtlasRegion,TileContainer>();


		renderMeshes = true;

		var drawOrder:Array<Slot> = skeleton.drawOrder;
		for (slot in drawOrder)
		{
			if (slot.attachment == null)
			{
				continue;
			}

			if (Std.is(slot.attachment, MeshAttachment))
			{
				renderMeshes = true;
				break;
			}
		}

		this.renderMeshes = renderMeshes;

		_tempVerticesArray = new Array<Float>();
		_quadTriangles = new Array<Int>();
		_quadTriangles[0] = 0;
		_quadTriangles[1] = 1;
		_quadTriangles[2] = 2;
		_quadTriangles[3] = 2;
		_quadTriangles[4] = 3;
		_quadTriangles[5] = 0;
		_colors = new Array<Int>();

		// addEventListener(Event.ENTER_FRAME, enterFrame);
	}
	
	public function destroy():Void {
		// removeEventListener(Event.ENTER_FRAME, enterFrame);
		// removeChildren();
		// graphics.clear();
	}
	
	public function start():Void {
		// if (!hasEventListener(Event.ENTER_FRAME)) {
		// 	addEventListener(Event.ENTER_FRAME, enterFrame);
		// }
	}

	public function stop():Void {
		// if (hasEventListener(Event.ENTER_FRAME)) {
		// 	removeEventListener(Event.ENTER_FRAME, enterFrame);
		// }
	}

	public function update():Void {
		var time:Int = Std.int(haxe.Timer.stamp() * 1000);
		advanceTime((time - lastTime) / 1000);
		lastTime = time;
	}

	public function advanceTime (delta:Float):Void {
		skeleton.update(delta * timeScale);
		renderTriangles();
	}

	function renderTriangles():Void
	{
		var allVertices:Vector<Float> = new Vector<Float>();
		var allTriangles:Vector<Int> = new Vector<Int>();
		var allUvs:Vector<Float> = new Vector<Float>();

		var drawOrder:Array<Slot> = skeleton.drawOrder;
		var n:Int = drawOrder.length;
		var worldVertices:Vector<Float>;
		var triangles:Array<Int> = null;
		var uvs:Array<Float> = null;
		var verticesLength:Int = 0;
		var numVertices:Int;
		var atlasRegion:AtlasRegion;
		var bitmapData:BitmapData = null;
		var slot:Slot;
		var r:Float = 0, g:Float = 0, b:Float = 0, a:Float = 0;
		var color:Int;
		var blend:Int;

		// graphics.clear();
		// this.removeTiles();
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


				allVertices = allVertices.concat(ofArrayFloat(_tempVerticesArray));
				allTriangles = allTriangles.concat(ofArrayInt(triangles));
				allUvs = allUvs.concat(ofArrayFloat(uvs));


				//矩形绘制
				if(atlasRegion != null)
				{
					// this.graphics.beginFill(0xff0000,1);
					this.graphics.beginBitmapFill(cast atlasRegion.page.rendererObject,null,true,true);
					this.graphics.drawTriangles(ofArrayFloat(_tempVerticesArray),ofArrayInt(triangles),ofArrayFloat(uvs),TriangleCulling.NONE);
					this.graphics.endFill();
				}

				
			}
		}
		// trace("allVertices="+allVertices.length,allVertices);
		// trace("allTriangles="+allTriangles.length);
		// trace("allUvs="+allUvs.length);
		// this.graphics.drawTriangles(allVertices,allTriangles,allUvs,TriangleCulling.NONE);
		// this.graphics.endFill();
	}

	function ofArrayInt(data:Array<Int>):Vector<Int>
	{
		var v:Vector<Int> = new Vector<Int>();
		for(i in 0...data.length)
			v.set(i,data[i]);
		return v;
	}

	function ofArrayFloat(data:Array<Float>):Vector<Float>
	{
		var v:Vector<Float> = new Vector<Float>();
		for(i in 0...data.length)
			v.set(i,data[i]);
		return v;
	}

	function set_renderMeshes(value:Bool):Bool
	{
		// removeChildren();
		// graphics.clear();
		return renderMeshes = value;
	}
}
