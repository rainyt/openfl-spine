package;

import haxe.io.Path;
import zygame.display.batch.ImageBatchs;
import zygame.utils.ZAssets;
import zygame.core.Start;

class Main extends Start {
	public function new() {
		super(1920, 1080, true);
	}

	override function onInit() {
		super.onInit();
		// 代码初始化入口
		var assets:ZAssets = new ZAssets();
		#if spine4_2
		var spine1 = "magicThunder";
		#else
		var spine1 = "3.8/magicThunder";
		#end
		assets.loadSpineTextAlats(["assets/" + spine1 + ".png"], "assets/" + spine1 + ".atlas");
		// assets.loadFile("assets/" + spine1 + ".json");
		assets.loadFile("assets/" + spine1 + ".skel");
		var spine2 = "ORole";
		assets.loadSpineTextAlats(["assets/" + spine2 + ".png"], "assets/" + spine2 + ".atlas");
		assets.loadFile("assets/" + spine2 + ".json");
		assets.start((f) -> {
			if (f == 1) {
				trace("加载完成");
				// Sprite
				var spine1name = Path.withoutDirectory(spine1);
				for (i in 0...100) {
					var spine = assets.createSpineSpriteSkeleton(spine1name, spine1name);
					this.addChild(spine);
					// spine.x = getStageWidth() / 2 + 300;
					// spine.y = getStageHeight() / 2 + 200;
					spine.x = Std.random(Std.int(getStageWidth()));
					spine.y = Std.random(Std.int(getStageHeight()));
					spine.play("idle");
					spine.scale(1);
					spine.smoothing = true;
					#if spine4_2
					spine.skeleton.skinName = "rn1004";
					#else
					spine.skeleton.setSkinByName("rn1004");
					#end
				}

				#if spine4_2
				// Tilemap
				var spine = assets.createSpineTilemapSkeleton(spine2, spine2);
				var tilemap = new ImageBatchs(assets.getSpineTextureAlats(spine2));
				tilemap.smoothing = true;
				this.addChild(tilemap);
				tilemap.addChild(spine);
				spine.x = getStageWidth() / 2 - 300;
				spine.y = getStageHeight() / 2 + 200;
				spine.play("run");
				spine.scale(0.3);
				#end
			}
		});
	}
}
