package spine.shader;

import VectorMath;

@:debug
class SpineGPURenderShader extends SpineRenderShader {
	/**
	 * 获得单独的shader
	 */
	public static var shader(get, never):SpineGPURenderShader;

	private static var _shader:SpineGPURenderShader;

	private static function get_shader():SpineGPURenderShader {
		if (_shader == null)
			_shader = new SpineGPURenderShader();
		return _shader;
	}

	/**
	 * 骨骼数据：(暂提供58个骨骼支持)
	 * x,y,rotation
	 * scaleX,scaleY,none
	 */
	@:arrayLen(28)
	@:uniform public var bonesMatrix:Array<Mat4>;

	/**
	 * 骨骼索引
	 */
	@:attribute public var boneIndex:Float;

	/**
	 * 顶点着色器
	 */
	override function vertex() {
		super.vertex();
		alphaBlendMode = vec2(texalpha, texblendmode);
		mulcolor = texcolor;
		muldarkcolor = darkcolor;
		var mat:Mat4 = gl_openfl_Matrix;
		mat *= bonesMatrix[int(boneIndex)];
		// mat *= bonesMatrix[0];
		// var mat:Mat4 = bonesMatrix[0];
		// mat = gl_openfl_Matrix * mat;
		gl_Position = mat * gl_openfl_Position;
	}

	/**
	 * 像素着色器
	 */
	override function fragment() {
		super.fragment();
		gl_FragColor = color * alphaBlendMode.x;
		gl_FragColor.a = gl_FragColor.a * (1. - alphaBlendMode.y);
		gl_FragColor.rgb = (gl_FragColor.rgb * mulcolor.rgb + ((1. - gl_FragColor.rgb) * muldarkcolor.rgb) * gl_FragColor.a);
		gl_FragColor = gl_FragColor * malpha;
	}

	public function int(a:Dynamic):Dynamic {
		return a;
	}
}
