package;

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
		assets.loadSpineTextAlats(["assets/snowglobe-pro.png"], "assets/snowglobe-pro.atlas");
		assets.loadFile("assets/snowglobe-pro.json");
		assets.loadSpineTextAlats(["assets/ORole.png"], "assets/ORole.atlas");
		assets.loadFile("assets/ORole.json");
		assets.start((f) -> {
			if (f == 1) {
				trace("加载完成");
				// Sprite
				var spine = assets.createSpineSpriteSkeleton("snowglobe-pro", "snowglobe-pro");
				this.addChild(spine);
				spine.x = getStageWidth() / 2 + 300;
				spine.y = getStageHeight() / 2 + 200;
				spine.play("idle");
				spine.scale(0.3);
				spine.smoothing = true;

				// Tilemap
				var spine = assets.createSpineTilemapSkeleton("ORole", "ORole");
				var tilemap = new ImageBatchs(assets.getSpineTextureAlats("ORole"));
				tilemap.smoothing = true;
				this.addChild(tilemap);
				tilemap.addChild(spine);
				spine.x = getStageWidth() / 2 - 300;
				spine.y = getStageHeight() / 2 + 200;
				spine.play("run");
				spine.scale(0.3);
			}
		});
	}
}
