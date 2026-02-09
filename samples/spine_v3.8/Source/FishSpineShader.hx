package;

import spine.shader.SpineRenderShader;
import VectorMath;

/**
 * 鱼的着色器
 */
class FishSpineShader extends SpineRenderShader {

	override function fragment() {
		super.fragment();
		gl_FragColor = color * alphaBlendMode.x;
		gl_FragColor.a = gl_FragColor.a * (1 - alphaBlendMode.y);
		gl_FragColor.rgb = gl_FragColor.rgb * mulcolor.rgb;
		gl_FragColor = gl_FragColor * malpha;
		// 取灰度
		var h:Float = (gl_FragColor.r + gl_FragColor.g + gl_FragColor.b) / 3;
		gl_FragColor.rgb = vec3(h) * vec3(0.7, 1, 1);
        // 然后变亮
		gl_FragColor.rgba += vec4(0.2) * gl_FragColor.a;
	}
}
