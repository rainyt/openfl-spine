package spine.shader;

import glsl.GLSL.texture2D;
import glsl.Sampler2D;
import glsl.OpenFLGraphicsShader;
import VectorMath;

/**
 * 用于实现Spine在Sprite模式下的透明值、BlendMode等支持
 */
@:autoBuild(glsl.macro.GLSLCompileMacro.build())
class SpineRenderShader extends OpenFLGraphicsShader {
	/**
	 * 获得单独的shader
	 */
	public static var shader(get, never):SpineRenderShader;

	private static var _shader:SpineRenderShader;

	private static function get_shader():SpineRenderShader {
		if (_shader == null)
			_shader = new SpineRenderShader();
		return _shader;
	}

	/**
	 * 纹理透明度
	 */
	@:attribute public var texalpha:Float;

	/**
	 * BlendMode: 1:BlendMode.ADD
	 */
	@:attribute public var texblendmode:Float;

	/**
	 * 颜色变更：rgba，其中a代表是否需要计算颜色变更
	 */
	@:attribute public var texcolor:Vec4;

	@:attribute public var darkcolor:Vec4;

	/**
	 * x:透明度
	 * y:BlendMode
	 */
	@:varying public var alphaBlendMode:Vec2;

	/**
	 * 颜色相乘
	 */
	@:varying public var mulcolor:Vec4;

	@:varying public var muldarkcolor:Vec4;

	@:uniform public var hasColorTransform:Bool;

	@:uniform public var colorOffset:Vec4;

	@:uniform public var colorMultiplier:Vec4;

	/**
	 * Shader版本号
	 */
	public var shaderVersion:Int = 0;

	public function new() {
		super();
	}

	override function fragment() {
		var color:Vec4 = texture2D(bitmap, gl_openfl_TextureCoordv);
		if (color.a == 0.0) {
			gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
		} else if (hasColorTransform) {
			color = vec4(color.rgb / color.a, color.a);
			var p_colorMultiplier:Mat4 = mat4(0);
			p_colorMultiplier[0][0] = colorMultiplier.x;
			p_colorMultiplier[1][1] = colorMultiplier.y;
			p_colorMultiplier[2][2] = colorMultiplier.z;
			p_colorMultiplier[3][3] = 1.0; // openfl_ColorMultiplierv.w;
			color = clamp(colorOffset + (color * p_colorMultiplier), 0.0, 1.0);
			if (color.a > 0.0) {
				gl_FragColor = vec4(color.rgb * color.a * gl_openfl_Alphav, color.a * gl_openfl_Alphav);
				gl_FragColor = gl_FragColor * alphaBlendMode.x;
				gl_FragColor.a = gl_FragColor.a * (1. - alphaBlendMode.y);
				gl_FragColor.rgb = (gl_FragColor.rgb * mulcolor.rgb + ((1. - gl_FragColor.rgb) * muldarkcolor.rgb * mulcolor.rgb) * gl_FragColor.a);
			} else {
				gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
			}
		} else {
			gl_FragColor = color * gl_openfl_Alphav;
			gl_FragColor = gl_FragColor * alphaBlendMode.x;
			gl_FragColor.a = gl_FragColor.a * (1. - alphaBlendMode.y);
			gl_FragColor.rgb = (gl_FragColor.rgb * mulcolor.rgb + ((1. - gl_FragColor.rgb) * muldarkcolor.rgb * mulcolor.rgb) * gl_FragColor.a);
		}
	}

	/**
	 * 顶点着色器
	 */
	override function vertex() {
		super.vertex();
		alphaBlendMode = vec2(texalpha, texblendmode);
		mulcolor = texcolor;
		muldarkcolor = darkcolor;
	}
}
