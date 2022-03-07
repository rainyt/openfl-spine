import spine.openfl.SkeletonGPUAnimation;
import zygame.utils.SpineManager;
import zygame.utils.load.SpineTextureAtlasLoader;
import openfl.utils.Assets;
import openfl.display.Sprite;

class GPUMain extends Sprite {
	public function new() {
		super();
		SpineManager.init(stage);
		// var id:String = "btn_mianfeifuli";
		var id:String = "sxkCenter";
		var jsonData:String = Assets.getText("assets/" + id + ".json");
		var spineTextureAtals:SpineTextureAtlasLoader = new SpineTextureAtlasLoader("assets/" + id + ".atlas", ["assets/" + id + ".png"]);
		spineTextureAtals.load(function(textureAtals:SpineTextureAtlas):Void {
			// GPU
			for (i in 0...100) {
				var spriteSpine:SkeletonGPUAnimation = textureAtals.buildGPUSpriteSkeleton(id, jsonData);
				this.addChild(spriteSpine);
				spriteSpine.y = 200;
				spriteSpine.x = 400;
				spriteSpine.play("daiji");
				spriteSpine.scaleX = 0.6;
				spriteSpine.scaleY = 0.6;
			}

			// CPU
			// for (i in 0...100) {
			// 	var spriteSpine = textureAtals.buildSpriteSkeleton(id, jsonData);
			// 	this.addChild(spriteSpine);
			// 	spriteSpine.y = 200;
			// 	spriteSpine.x = 200;
			// 	spriteSpine.play("daiji");
			// 	spriteSpine.scaleX = 0.6;
			// 	spriteSpine.scaleY = 0.6;
			// }
		}, function(error:String):Void {
			trace("加载失败：", error);
		});
	}
}
