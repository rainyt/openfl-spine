package;

import openfl.display.Bitmap;
import spine.shader.SpineRenderShader;
import openfl.Lib;
import zygame.utils.SpineManager;
import openfl.display.Tilemap;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.utils.Assets;
import zygame.utils.load.SpineTextureAtlasLoader;

/**
 * SpineDemo
 */
class Main extends Sprite {
	public function new() {
		super();
		this.addEventListener(Event.ADDED_TO_STAGE, onInit);
	}

	public function onInit(e:Event):Void {
		stage.color = 0xbbbbbb;
		SpineManager.init(stage);

		var fps:openfl.display.FPS = new openfl.display.FPS();
		fps.textColor = 0xffffff;
		this.addChild(fps);

		var jsonData:String = Assets.getText("assets/snowglobe-pro.json");
		var spineTextureAtals:SpineTextureAtlasLoader = new SpineTextureAtlasLoader("assets/snowglobe-pro.atlas", ["assets/snowglobe-pro.png"]);
		spineTextureAtals.load(function(textureAtals:SpineTextureAtlas):Void {
			// Sprite
			var bmd = new Bitmap(@:privateAccess textureAtals._bitmapDatas.iterator().next());
			this.addChild(bmd);
			var spine = textureAtals.buildSpriteSkeleton("snowglobe-pro", jsonData);
			this.addChild(spine);
			spine.y = stage.stageHeight * 0.8;
			spine.x = stage.stageWidth / 2;
			spine.play("idle");
			spine.scaleX = 0.2;
			spine.scaleY = 0.2;
		}, function(error:String):Void {
			trace("加载失败：", error);
		});
	}
}
