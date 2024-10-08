package;

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
		// var jsonData:String = Assets.getText("assets/bonus.json");
		// var spineTextureAtals:SpineTextureAtlasLoader = new SpineTextureAtlasLoader("assets/bonus.atlas",["assets/bonus.png"]);
		// spineTextureAtals.load(function(textureAtals:SpineTextureAtals):Void{
		//     // Sprite格式
		//     for(i in 0...60)
		//     {
		//         var openflSprite = textureAtals.buildSpriteSkeleton("bonus",jsonData);
		//         this.addChild(openflSprite);
		//         openflSprite.y = 300;
		//         openflSprite.x = Math.random()*stage.stageWidth;
		//         openflSprite.play("animation");
		//         openflSprite.scaleX = 0.6;
		//         openflSprite.scaleY = 0.6;
		//         openflSprite.isNative = false;
		//     }
		// },function(error:String):Void{
		//     trace("加载失败：",error);
		// });

		#if !(spine38 || spine4)
		var jsonData:String = Assets.getText("assets/sxkCenter.json");
		var spineTextureAtals:SpineTextureAtlasLoader = new SpineTextureAtlasLoader("assets/sxkCenter.atlas", ["assets/sxkCenter.png"]);
		spineTextureAtals.load(function(textureAtals:SpineTextureAtlas):Void {
			// tilemap格式
			var tilemap:Tilemap = new Tilemap(stage.stageWidth, stage.stageHeight, textureAtals.loader.getTileset());
			for (i in 0...30) {
				var tilemapSprite = textureAtals.buildTilemapSkeleton("sxkCenter", jsonData);
				this.addChild(tilemap);
				tilemap.addTile(tilemapSprite);
				tilemapSprite.y = 200;
				tilemapSprite.x = Math.random() * stage.stageWidth;
				tilemapSprite.play("run");
				tilemapSprite.scaleX = 0.6;
				tilemapSprite.scaleY = 0.6;
			}
		}, function(error:String):Void {
			trace("加载失败：", error);
		});
		#elseif spine4
		// Sprite
		var jsonData:String = Assets.getText("assets/symZ_expand.json");
		var spineTextureAtals:SpineTextureAtlasLoader = new SpineTextureAtlasLoader("assets/symZ_expand.atlas", ["assets/symZ_expand.png"]);
		spineTextureAtals.load(function(textureAtals:SpineTextureAtlas):Void {
			// Sprite格式
			for (i in 0...1) {
				var spriteSpine = textureAtals.buildSpriteSkeleton("symZ_expand", jsonData);
				this.addChild(spriteSpine);
				// spriteSpine.isCache = true;
				trace("spriteSpine.isCache=", spriteSpine.isCache);
				spriteSpine.y = 400;
				spriteSpine.x = 400;
				spriteSpine.play("looped");
				spriteSpine.scaleX = 0.6;
				spriteSpine.scaleY = 0.6;
				// Tilemap
				// var tilemapSpine = textureAtals.buildTilemapSkeleton("symZ_expand", jsonData);
			}
		}, function(error:String):Void {
			trace("加载失败：", error);
		});
		#else
		var spineJsonData:String = Assets.getText("assets/unrote_cut/fx_saltCow2_skill.json");
		var spineTextureAtals:SpineTextureAtlasLoader = new SpineTextureAtlasLoader("assets/unrote_cut/fx_saltCow2_skill.atlas", ["assets/unrote_cut/fx_saltCow2_skill.png"]);
		spineTextureAtals.load(function(textureAtals:SpineTextureAtlas):Void {
			// Sprite格式
			for (i in 0...30) {
				var spriteSpine = textureAtals.buildSpriteSkeleton("fx_saltCow2_skill", spineJsonData);
				spriteSpine.isCache = true;
				trace("spriteSpine.isCache=", spriteSpine.isCache);
				spriteSpine.y = Std.random(stage.stageWidth);
				spriteSpine.x = Std.random(stage.stageWidth);
				spriteSpine.play("idle");
				spriteSpine.skeleton.setSkinByName("blue");
				this.addChild(spriteSpine);
				spriteSpine.scaleX = spriteSpine.scaleY = 0.5;
			}
		}, function(error:String):Void {
			trace("加载失败：", error);
		});
		#end

		var fps:openfl.display.FPS = new openfl.display.FPS();
		fps.textColor = 0xffffff;
		this.addChild(fps);
	}
}
