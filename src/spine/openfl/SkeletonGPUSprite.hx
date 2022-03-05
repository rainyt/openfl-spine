package spine.openfl;

import lime.utils.Float32Array;
import openfl.Lib;
import openfl.display.OpenGLRenderer;
import openfl.events.RenderEvent;
import lime.math.Vector4;
import lime.math.Matrix4;
import spine.support.math.Matrix3;
import zygame.utils.SpineManager;
import openfl.Vector;
import openfl.display.BitmapData;
import spine.attachments.RegionAttachment;
import spine.openfl.gpu.SoltData;
import openfl.display.Sprite;
import spine.shader.SpineGPURenderShader;
import openfl.display3D.Context3DTextureFilter;

/**
 * Bate：该功能为实验性功能，未完成
 * 使用GPU渲染骨骼动画，当前模式下，不能使用BlendMode.ADD等渲染模式
 */
class SkeletonGPUSprite extends Sprite implements spine.base.SpineBaseDisplay {
	public var smoothing:Bool = true;

	/**
	 * 骨架对象
	 */
	public var skeleton:Skeleton;

	/**
	 * 是否正在播放
	 */
	public var isPlay(get, set):Bool;

	private var _isPlay:Bool = false;

	/**
	 * 渲染帧率是否独立
	 */
	public var independent:Bool;

	/**
	 * 骨骼数据绑定
	 */
	private var _soltDataMaps:Map<Slot, SoltData> = [];

	public function new(skeletonData:SkeletonData) {
		super();
		// 初始化骨架
		skeleton = new Skeleton(skeletonData);
		#if (spine_hx <= "3.6.0")
		skeleton.setFlipY(true);
		#else
		skeleton.setScaleY(-1);
		#end
		skeleton.updateWorldTransform();
		this.initSkeletonData();
		#if !zygame
		this.addEventListener(openfl.events.Event.ADDED_TO_STAGE, onAddToStage);
		this.addEventListener(openfl.events.Event.REMOVED_FROM_STAGE, onRemoveToStage);
		#end
		this.addEventListener(openfl.events.RenderEvent.RENDER_OPENGL, onRender);
	}

	/**
	 * 开始初始化骨骼的顶点数据
	 */
	private function initSkeletonData():Void {
		for (slot in skeleton.drawOrder) {
			trace(slot.attachment);
			var soltData = new SoltData(slot);
			_soltDataMaps.set(slot, soltData);
		}
		onSpineUpdate(0);
	}

	private function get_isPlay():Bool {
		if (_isPlay)
			return true;
		return false;
	}

	private function set_isPlay(bool:Bool):Bool {
		_isPlay = bool;
		return bool;
	}

	private var _isHidden:Bool = false;

	public function isHidden():Bool {
		_isHidden = this.__worldAlpha == 0 || !this.__visible;
		return _isHidden;
	}

	public function onSpineUpdate(dt:Float) {
		advanceTime(dt);
		renderGPUAnimate();
	}

	public function advanceTime(dt:Float) {}

	private function renderGPUAnimate():Void {
		// 渲染
		var _shader = SpineGPURenderShader.shader;
		// todo 这里应该需要处理一下drawOrder循序是否发生变化，如果没有变化，这4个变量都不需要发生变化
		var allvertices:Vector<Float> = new Vector();
		var alluvs:Vector<Float> = new Vector();
		var alltriangles:Vector<Int> = new Vector();
		var allTrianglesAlpha:Array<Float> = [];
		var allTrianglesBlendMode:Array<Float> = [];
		var allTrianglesColor:Array<Float> = [];
		var allTrianglesDarkColor:Array<Float> = [];
		var allBoneIndex:Array<Float> = [];
		var bonesMatrix:Array<Float> = [];
		var drawBitmapData:BitmapData = null;
		var t = 0;
		var bondIndex = 0;
		for (slot in skeleton.drawOrder) {
			var boneData = _soltDataMaps.get(slot);
			if (boneData != null && boneData.vertices != null) {
				var verticesCounts = Std.int(boneData.vertices.length / 2);
				for (f in boneData.vertices) {
					allvertices.push(f);
				}
				for (f in boneData.uvs) {
					alluvs.push(f);
				}
				for (i in boneData.triangles) {
					alltriangles.push(t + i);
				}
				if (drawBitmapData == null && boneData.bitmapData != null) {
					drawBitmapData = boneData.bitmapData;
				}

				for (i in 0...boneData.triangles.length) {
					allTrianglesAlpha.push(1);
					allTrianglesBlendMode.push(0);

					allTrianglesColor.push(1);
					allTrianglesColor.push(1);
					allTrianglesColor.push(1);
					allTrianglesColor.push(1);

					allTrianglesDarkColor.push(0);
					allTrianglesDarkColor.push(0);
					allTrianglesDarkColor.push(0);
					allTrianglesDarkColor.push(0);

					allBoneIndex.push(bondIndex);
				}
				t += Std.int(boneData.uvs.length / 2);
				// 骨骼数据
				if (Std.isOfType(slot.attachment, RegionAttachment)) {
					var attachment:RegionAttachment = cast slot.attachment;
					var m4 = new Matrix4();
					m4.appendScale(attachment.getScaleX(), attachment.getScaleY(), 0);
					m4.appendRotation(attachment.getRotation(), new Vector4(0, 0, 1));
					m4.appendTranslation(attachment.getX(), attachment.getY(), 0);
					for (i in 0...16) {
						bonesMatrix.push(m4[i]);
					}
				}
				// trace(m4);
				bondIndex++;
			}
		}
		trace(bonesMatrix);
		#if zygame
		if (Std.isOfType(this.parent, zygame.components.ZSpine)) {
			_shader.data.u_malpha.value = [this.parent.alpha * this.alpha];
		} else {
			_shader.data.u_malpha.value = [this.alpha];
		}
		#else
		_shader.data.u_malpha.value = [this.alpha];
		#end
		_shader.u_bonesMatrix.value = bonesMatrix;
		_shader.bitmap.input = drawBitmapData;
		// Smoothing
		_shader.data.bitmap.filter = smoothing ? LINEAR : NEAREST;
		_shader.a_boneIndex.value = allBoneIndex;
		_shader.a_texalpha.value = allTrianglesAlpha;
		_shader.a_texblendmode.value = allTrianglesBlendMode;
		_shader.a_texcolor.value = allTrianglesColor;
		_shader.a_darkcolor.value = allTrianglesDarkColor;
		this.graphics.clear();
		this.graphics.beginShaderFill(_shader);
		this.graphics.drawTriangles(allvertices, alltriangles, alluvs);
		this.graphics.endFill();
	}

	private function onRender(e:RenderEvent):Void {
		var opengl:OpenGLRenderer = cast e.renderer;
		var gl = opengl.gl;
		var context = Lib.application.window.stage.context3D;
		// 这里传递长数组
		var _shader = SpineGPURenderShader.shader;
		gl.uniformMatrix4fv(_shader.u_bonesMatrix.index, false, new Float32Array(_shader.u_bonesMatrix.value));
	}

	public function getMaxTime():Float {
		return 0;
	}

	#if zygame
	/**
	 * 当从舞台移除时
	 */
	override public function onRemoveToStage():Void {
		SpineManager.removeOnFrame(this);
	}

	override public function onAddToStage():Void {
		SpineManager.addOnFrame(this);
	}
	#else

	/**
	 * 当从舞台移除时
	 */
	public function onRemoveToStage(_):Void {
		SpineManager.removeOnFrame(this);
	}

	public function onAddToStage(_):Void {
		SpineManager.addOnFrame(this);
	}
	#end
}

class GPUMatrix3 extends Matrix3 {
	public function new() {}
}
