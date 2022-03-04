import zygame.utils.SpineManager;
import zygame.utils.load.SpineTextureAtlasLoader;
import openfl.utils.Assets;
import openfl.display.Sprite;

class GPUMain extends Sprite {
	public function new() {
		super();
		SpineManager.init(stage);
		var jsonData:String = Assets.getText("assets/sxkCenter.json");
		var spineTextureAtals:SpineTextureAtlasLoader = new SpineTextureAtlasLoader("assets/sxkCenter.atlas", ["assets/sxkCenter.png"]);
		spineTextureAtals.load(function(textureAtals:SpineTextureAtlas):Void {
			// GPU
			var spriteSpine = textureAtals.buildGPUSpriteSkeleton("sxkCenter", jsonData);
			this.addChild(spriteSpine);
			spriteSpine.y = 200;
			spriteSpine.x = 400;
			spriteSpine.play("daiji");
			spriteSpine.scaleX = 0.6;
			spriteSpine.scaleY = 0.6;
			// CPU
			var spriteSpine = textureAtals.buildSpriteSkeleton("sxkCenter", jsonData);
			this.addChild(spriteSpine);
			spriteSpine.y = 200;
			spriteSpine.x = 200;
			spriteSpine.play("daiji");
			spriteSpine.scaleX = 0.6;
			spriteSpine.scaleY = 0.6;
		}, function(error:String):Void {
			trace("加载失败：", error);
		});
	}
}
