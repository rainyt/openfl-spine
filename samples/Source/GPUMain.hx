import zygame.utils.load.SpineTextureAtlasLoader;
import openfl.utils.Assets;
import openfl.display.Sprite;

class GPUMain extends Sprite {
	public function new() {
		super();
		var jsonData:String = Assets.getText("assets/sxkCenter.json");
		var spineTextureAtals:SpineTextureAtlasLoader = new SpineTextureAtlasLoader("assets/sxkCenter.atlas", ["assets/sxkCenter.png"]);
		spineTextureAtals.load(function(textureAtals:SpineTextureAtlas):Void {
			// GPU
			var spriteSpine = textureAtals.buildSpriteSkeleton("symZ_expand", jsonData);
			this.addChild(spriteSpine);
			// spriteSpine.isCache = true;
			trace("spriteSpine.isCache=", spriteSpine.isCache);
			spriteSpine.y = 400;
			spriteSpine.x = 400;
			spriteSpine.play("looped");
			spriteSpine.scaleX = 0.6;
			spriteSpine.scaleY = 0.6;
		}, function(error:String):Void {
			trace("加载失败：", error);
		});
	}
}
