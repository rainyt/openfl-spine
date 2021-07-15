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

	/**
	 * x:透明度
	 * y:BlendMode
	 */
	@:varying public var alphaBlendMode:Vec2;

	/**
	 * 颜色相乘
	 */
	@:varying public var mulcolor:Vec4;

	/**
	 * 透明度
	 */
	@:uniform public var malpha:Float;

	/**
	 * 着色器名字
	 */
	private var _shaderClassName:String = null;

	public function new() {
		super();
		_shaderClassName = Type.getClassName(Type.getClass(this));
	}

	override function fragment() {
		super.fragment();
		gl_FragColor = color * alphaBlendMode.x;
		gl_FragColor.a = gl_FragColor.a * (1 - alphaBlendMode.y);
		gl_FragColor.rgb = gl_FragColor.rgb * mulcolor.rgb;
		gl_FragColor = gl_FragColor * malpha;
	}

	/**
	 * 顶点着色器
	 */
	override function vertex() {
		super.vertex();
		alphaBlendMode = vec2(texalpha, texblendmode);
		mulcolor = texcolor;
	}

	/**
	 * 获取着色器
	 * @return String
	 */
	public function getShaderClass():String {
		return _shaderClassName;
	}
}
