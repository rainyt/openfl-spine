#if !spine4_2
#if api_lang_en
/**
 * Batch render shader for Spine
 * Implements support for position, scale, and rotation for batch rendering
 */
#else
/**
 * 为批渲染对象实现XY/SCALE等支持
 */
#end
package spine.shader;

import VectorMath;

class SpineRenderBatchShader extends SpineRenderShader {
	#if api_lang_en
	/**
	 * Vertex position offset
	 */
	#else
	/**
	 * 顶点位移
	 */
	#end
	@:attribute public var xy:Vec2;

	#if api_lang_en
	/**
	 * Vertex scale and rotation
	 * x: scale X, y: scale Y, z: rotation degrees
	 */
	#else
	/**
	 * 顶点缩放、旋转
	 * x: 缩放X, y: 缩放Y, z: 旋转角度
	 */
	#end
	@:attribute public var scaleAndRotation:Vec3;

	#if api_lang_en
	/**
	 * Size uniform
	 */
	#else
	/**
	 * 尺寸
	 */
	#end
	@:uniform public var size:Vec2;

	#if api_lang_en
	/**
	 * Rotation implementation
	 * @param degrees Rotation degrees
	 * @param axis Rotation axis
	 * @param ts Translation vector
	 * @return Rotation matrix
	 */
	#else
	/**
	 * 旋转实现
	 * @param degrees 旋转角度
	 * @param axis 旋转轴
	 * @param ts 平移向量
	 * @return 旋转矩阵
	 */
	#end
	@:vertexglsl public function rotaion(degrees:Float, axis:Vec3, ts:Vec3):Mat4 {
		var tx:Float = ts.x;
		var ty:Float = ts.y;
		var tz:Float = ts.z;

		var radian:Float = degrees * 3.14 / 180;
		var c:Float = cos(radian);
		var s:Float = sin(radian);
		var x:Float = axis.x;
		var y:Float = axis.y;
		var z:Float = axis.z;
		var x2:Float = x * x;
		var y2:Float = y * y;
		var z2:Float = z * z;
		var ls:Float = x2 + y2 + z2;
		if (ls != 0) {
			var l:Float = sqrt(ls);
			x /= l;
			y /= l;
			z /= l;
			x2 /= ls;
			y2 /= ls;
			z2 /= ls;
		}
		var ccos:Float = 1 - c;
		var d:Mat4 = gl_openfl_Matrix;
		d[0].x = x2 + (y2 + z2) * c;
		d[0].y = x * y * ccos + z * s;
		d[0].z = x * z * ccos - y * s;
		d[1].x = x * y * ccos - z * s;
		d[1].y = y2 + (x2 + z2) * c;
		d[1].z = y * z * ccos + x * s;
		d[2].x = x * z * ccos + y * s;
		d[2].y = y * z * ccos - x * s;
		d[2].z = z2 + (x2 + y2) * c;
		d[3].x = (tx * (y2 + z2) - x * (ty * y + tz * z)) * ccos + (ty * z - tz * y) * s;
		d[3].y = (ty * (x2 + z2) - y * (tx * x + tz * z)) * ccos + (tz * x - tx * z) * s;
		d[3].z = (tz * (x2 + y2) - z * (tx * x + ty * y)) * ccos + (tx * y - ty * x) * s;
		return d;
	}

	#if api_lang_en
	/**
	 * Scale implementation
	 * @param xScale Scale factor for X axis
	 * @param yScale Scale factor for Y axis
	 * @return Scale matrix
	 */
	#else
	/**
	 * 比例缩放
	 * @param xScale X轴缩放因子
	 * @param yScale Y轴缩放因子
	 * @return 缩放矩阵
	 */
	#end
	@:vertexglsl public function scaleXY(xScale:Float, yScale:Float):Mat4 {
		return mat4(xScale, 0.0, 0.0, 0.0, 0.0, yScale, 0.0, 0.0, 0.0, 0.0, 1, 0.0, 0.0, 0.0, 0.0, 1.0);
	}

	#if api_lang_en
	/**
	 * Translation implementation
	 * @param x Translation for X axis
	 * @param y Translation for Y axis
	 * @return Translation matrix
	 */
	#else
	/**
	 * 平移
	 * @param x X轴平移
	 * @param y Y轴平移
	 * @return 平移矩阵
	 */
	#end
	@:vertexglsl public function translation(x:Float, y:Float):Mat4 {
		return mat4(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, x, y, 0, 0);
	}

	#if api_lang_en
	/**
	 * Vertex shader implementation
	 */
	#else
	/**
	 * 顶点着色器
	 */
	#end
	override function vertex() {
		super.vertex();
		var mat:Mat4 = gl_openfl_Matrix;
		var smat4:Mat4 = scaleXY(scaleAndRotation.x, scaleAndRotation.y);
		var rmat4:Mat4 = rotaion(scaleAndRotation.z, vec3(0, 0, 1), vec3(0, 0, 0));
		var uv:Vec2 = 2. / size.xy;
		var trans:Mat4 = translation(xy.x * uv.x, xy.y * uv.y);
		mat[3].x += trans[3].x;
		mat[3].y -= trans[3].y;
		alphaBlendMode = vec2(texalpha, texblendmode);
		mulcolor = texcolor;
		this.gl_Position = mat * smat4 * rmat4 * gl_openfl_Position;
	}
}
#end