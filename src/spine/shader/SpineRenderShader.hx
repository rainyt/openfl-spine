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

	/**
	 * 透明度
	 */
	@:uniform public var malpha:Float;

	/**
	 * Shader版本号
	 */
	public var shaderVersion:Int = 0;

	public function new() {
		super();
	}

	override function fragment() {
		super.fragment();
		gl_FragColor = color * alphaBlendMode.x;
		gl_FragColor.a = gl_FragColor.a * (1 - alphaBlendMode.y);
		gl_FragColor.rgb = (gl_FragColor.rgb * mulcolor.rgb + ((1 - gl_FragColor.rgb) * muldarkcolor.rgb) * gl_FragColor.a);
		gl_FragColor = gl_FragColor * malpha;
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
