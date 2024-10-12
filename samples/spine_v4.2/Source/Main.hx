package;

import openfl.text.TextFormat;
import openfl.text.TextField;
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

		// var spineName = "snowglobe-pro";
		// var spineName = "3.8/ORole";
		var spineName = "ORole";
		var jsonData:String = Assets.getText('assets/$spineName.json');
		var spineTextureAtals:SpineTextureAtlasLoader = new SpineTextureAtlasLoader('assets/$spineName.atlas', ['assets/$spineName.png']);
		spineTextureAtals.load(function(textureAtals:SpineTextureAtlas):Void {
			// Sprite
			var spine = textureAtals.buildSpriteSkeleton(spineName, jsonData);
			spine.smoothing = true;
			this.addChild(spine);
			spine.y = stage.stageHeight / 2;
			spine.x = stage.stageWidth / 2 + 200;
			// spine.play("eyeblink");
			spine.play("run");
			spine.scaleX = 0.2;
			spine.scaleY = 0.2;

			var label = new TextField();
			label.width = 300;
			label.text = "Sprite";
			label.setTextFormat(new TextFormat(null, 32, 0x0));
			this.addChild(label);
			label.x = spine.x - label.textWidth / 2;
			label.y = spine.y + 60;
		}, function(error:String):Void {
			trace("加载失败：", error);
		});

		// Tilemap渲染
		var spineName = "ORole";
		var jsonData:String = Assets.getText('assets/$spineName.json');
		var spineTextureAtals:SpineTextureAtlasLoader = new SpineTextureAtlasLoader('assets/$spineName.atlas', ['assets/$spineName.png']);
		spineTextureAtals.load(function(textureAtals:SpineTextureAtlas):Void {
			var tilemap = new Tilemap(this.stage.stageWidth, this.stage.stageHeight, textureAtals.loader.getTileset());
			var spine = textureAtals.buildTilemapSkeleton(spineName, jsonData);
			this.addChild(tilemap);
			tilemap.addTile(spine);
			spine.y = stage.stageHeight / 2;
			spine.x = stage.stageWidth / 2 - 200;
			// spine.play("eyeblink");
			spine.play("run");
			spine.scaleX = 0.2;
			spine.scaleY = 0.2;

			var label = new TextField();
			label.width = 300;
			label.text = "Tilemap";
			label.setTextFormat(new TextFormat(null, 32, 0x0));
			this.addChild(label);
			label.x = spine.x - label.textWidth / 2;
			label.y = spine.y + 60;
		}, function(error:String):Void {
			trace("加载失败：", error);
		});

		var fps:openfl.display.FPS = new openfl.display.FPS();
		fps.textColor = 0xffffff;
		this.addChild(fps);
	}
}
