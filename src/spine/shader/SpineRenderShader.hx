#if api_lang_en
/**
 * Render shader for Spine
 * Implements support for transparency, blend modes, and color transforms for Spine rendering
 */
#else
/**
 * 用于实现Spine在Sprite模式下的透明值、BlendMode等支持
 */
#end
package spine.shader;

import glsl.GLSL.texture2D;
import glsl.Sampler2D;
import glsl.OpenFLGraphicsShader;
import VectorMath;

@:autoBuild(glsl.macro.GLSLCompileMacro.build())
class SpineRenderShader extends OpenFLGraphicsShader {
	#if api_lang_en
	/**
	 * Gets a singleton instance of the shader
	 */
	#else
	/**
	 * 获得单独的shader
	 */
	#end
	public static var shader(get, never):SpineRenderShader;

	private static var _shader:SpineRenderShader;

	#if api_lang_en
	/**
	 * Gets the singleton shader instance
	 * @return Singleton shader instance
	 */
	#else
	/**
	 * 获取shader单例
	 * @return shader单例实例
	 */
	#end
	private static function get_shader():SpineRenderShader {
		if (_shader == null)
			_shader = new SpineRenderShader();
		return _shader;
	}

	#if api_lang_en
	/**
	 * Texture alpha value
	 */
	#else
	/**
	 * 纹理透明度
	 */
	#end
	@:attribute public var texalpha:Float;

	#if api_lang_en
	/**
	 * Blend mode
	 * 1: BlendMode.ADD
	 */
	#else
	/**
	 * BlendMode: 1:BlendMode.ADD
	 */
	#end
	@:attribute public var texblendmode:Float;

	#if api_lang_en
	/**
	 * Color transformation: rgba, where a indicates whether color transformation is needed
	 */
	#else
	/**
	 * 颜色变更：rgba，其中a代表是否需要计算颜色变更
	 */
	#end
	@:attribute public var texcolor:Vec4;

	#if api_lang_en
	/**
	 * Dark color
	 */
	#else
	/**
	 * 暗色
	 */
	#end
	@:attribute public var darkcolor:Vec4;

	#if api_lang_en
	/**
	 * Alpha and blend mode
	 * x: alpha, y: blend mode
	 */
	#else
	/**
	 * x:透明度
	 * y:BlendMode
	 */
	#end
	@:varying public var alphaBlendMode:Vec2;

	#if api_lang_en
	/**
	 * Color multiplication
	 */
	#else
	/**
	 * 颜色相乘
	 */
	#end
	@:varying public var mulcolor:Vec4;

	#if api_lang_en
	/**
	 * Dark color multiplication
	 */
	#else
	/**
	 * 暗色相乘
	 */
	#end
	@:varying public var muldarkcolor:Vec4;

	#if api_lang_en
	/**
	 * Whether color transformation is enabled
	 */
	#else
	/**
	 * 是否启用颜色变换
	 */
	#end
	@:uniform public var hasColorTransform:Bool;

	#if api_lang_en
	/**
	 * Color offset
	 */
	#else
	/**
	 * 颜色偏移
	 */
	#end
	@:uniform public var colorOffset:Vec4;

	#if api_lang_en
	/**
	 * Color multiplier
	 */
	#else
	/**
	 * 颜色乘数
	 */
	#end
	@:uniform public var colorMultiplier:Vec4;

	#if api_lang_en
	/**
	 * Shader version number
	 */
	#else
	/**
	 * Shader版本号
	 */
	#end
	public var shaderVersion:Int = 0;

	#if api_lang_en
	/**
	 * Creates a new SpineRenderShader
	 */
	#else
	/**
	 * 创建一个新的SpineRenderShader
	 */
	#end
	public function new() {
		super();
	}

	#if api_lang_en
	/**
	 * Fragment shader implementation
	 */
	#else
	/**
	 * 片元着色器实现
	 */
	#end
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
		alphaBlendMode = vec2(texalpha, texblendmode);
		mulcolor = texcolor;
		muldarkcolor = darkcolor;
	}
}
