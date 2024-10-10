package;

import spine.Physics;
import openfl.Vector;
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

		var spineName = "snowglobe-pro";
		// var spineName = "ORole";
		var jsonData:String = Assets.getText('assets/$spineName.json');
		var spineTextureAtals:SpineTextureAtlasLoader = new SpineTextureAtlasLoader('assets/$spineName.atlas', ['assets/$spineName.png']);
		spineTextureAtals.load(function(textureAtals:SpineTextureAtlas):Void {
			// Sprite
			var spine = textureAtals.buildSpriteSkeleton(spineName, jsonData);
			this.addChild(spine);
			spine.y = stage.stageHeight / 2;
			spine.x = stage.stageWidth / 2;
			// spine.play("eyeblink");
			spine.play("shake");
			spine.scaleX = 0.2;
			spine.scaleY = 0.2;

			var fps:openfl.display.FPS = new openfl.display.FPS();
			fps.textColor = 0xffffff;
			this.addChild(fps);
		}, function(error:String):Void {
			trace("加载失败：", error);
		});
	}
}
