package spine.shader;

import glsl.OpenFLGraphicsShader;
import glsl.GLSL;
import VectorMath;

/**
 * 用于实现Spine在Sprite模式下的透明值、BlendMode等支持
 */
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

	override function fragment() {
		super.fragment();
		gl_FragColor = color * alphaBlendMode.x * gl_openfl_Alphav;
		gl_FragColor.w *= (1 - alphaBlendMode.y);
		gl_FragColor.rgb *= mulcolor.rgb;
	}

	/**
	 * 顶点着色器
	 */
	override function vertex() {
		super.vertex();
		alphaBlendMode = vec2(texalpha, texblendmode);
		mulcolor = texcolor;
	}
}
