package;

import openfl.events.MouseEvent;
import spine.base.SpineBaseDisplay;
import ui.Button;
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

		var spineName = "snowglobe-pro";
		// var spineName = "3.8/ORole";
		// var spineName = "ORole";
		var jsonData:String = Assets.getText('assets/$spineName.json');
		// var bytesData = Assets.getBytes('assets/$spineName.skel');
		var spineTextureAtals:SpineTextureAtlasLoader = new SpineTextureAtlasLoader('assets/$spineName.atlas', ['assets/$spineName.png']);
		spineTextureAtals.load(function(textureAtals:SpineTextureAtlas):Void {
			// Sprite
			var spine = textureAtals.buildSpriteSkeleton(spineName, jsonData);
			spine.smoothing = true;
			this.addChild(spine);
			spine.y = stage.stageHeight / 2;
			spine.x = stage.stageWidth / 2 + 200;
			spine.play(spine.skeleton.data.animations[0].name);
			spine.scaleX = 0.2;
			spine.scaleY = 0.2;

			var length = spine.skeleton.data.animations.length;
			for (index => animation in spine.skeleton.data.animations) {
				for (animation2 in spine.skeleton.data.animations) {
					if (animation != animation2)
						spine.state.data.setMix(animation, animation2, 0.2);
				}
				this.bindAnimate(animation.name, stage.stageWidth - 80, stage.stageHeight / 2 - length * 40 / 2 + 40 * index, (name) -> {
					spine.play(name);
				});
			}

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
			spine.play(spine.skeleton.data.animations[0].name);
			spine.scaleX = 0.2;
			spine.scaleY = 0.2;

			var label = new TextField();
			label.width = 300;
			label.text = "Tilemap";
			label.setTextFormat(new TextFormat(null, 32, 0x0));
			this.addChild(label);
			label.x = spine.x - label.textWidth / 2;
			label.y = spine.y + 60;

			var length = spine.skeleton.data.animations.length;
			for (index => animation in spine.skeleton.data.animations) {
				for (animation2 in spine.skeleton.data.animations) {
					if (animation != animation2)
						spine.state.data.setMix(animation, animation2, 0.2);
				}
				this.bindAnimate(animation.name, 0, stage.stageHeight / 2 - length * 40 / 2 + 40 * index, (name) -> {
					spine.play(name);
				});
			}
		}, function(error:String):Void {
			trace("加载失败：", error);
		});

		var fps:openfl.display.FPS = new openfl.display.FPS();
		fps.textColor = 0xffffff;
		this.addChild(fps);
	}

	/**
	 * 绑定按钮
	 * @param animate 
	 * @param cb 
	 */
	public function bindAnimate(animate:String, x:Float, y:Float, cb:String->Void):Void {
		var button = new Button(animate);
		this.addChild(button);
		button.addEventListener(MouseEvent.CLICK, (e) -> {
			cb(animate);
		});
		button.x = x;
		button.y = y;
	}
}
