package spine.shader;

import VectorMath;

/**
 * 为批渲染对象实现XY/SCALE等支持
 */
class SpineRenderBatchShader extends SpineRenderShader {
	/**
	 * 顶点位移
	 */
	@:attribute public var xy:Vec2;

	/**
	 * 顶点缩放、旋转
	 */
	@:attribute public var scaleAndRotation:Vec3;

	/**
	 * 尺寸
	 */
	@:uniform public var size:Vec2;

	/**
	 * 旋转实现
	 * @return Mat4
	 */
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

	/**
	 * 比例缩放
	 * @param scaleX 
	 * @param scaleY 
	 */
	@:vertexglsl public function scaleXY(xScale:Float, yScale:Float):Mat4 {
		return mat4(xScale, 0.0, 0.0, 0.0, 0.0, yScale, 0.0, 0.0, 0.0, 0.0, 1, 0.0, 0.0, 0.0, 0.0, 1.0);
	}

	/**
	 * 平移
	 * @param x 
	 * @param y 
	 */
	@:vertexglsl public function translation(x:Float, y:Float):Mat4 {
		return mat4(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, x, y, 0, 0);
	}

	/**
	 * 顶点着色器
	 */
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
