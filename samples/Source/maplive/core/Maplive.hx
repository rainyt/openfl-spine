package maplive.core;


import zygame.utils.SpineManager;
import openfl.display.Tilemap;
import spine.SkeletonData;
import spine.SkeletonJson;
import spine.attachments.AtlasAttachmentLoader;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.BitmapData;
import openfl.utils.Assets;
import zygame.utils.load.SpineTextureAtlasLoader;

/**
 * 地图编辑器工具
 */
class Maplive extends Sprite{

    public function new(){
        super();
        this.addEventListener(Event.ADDED_TO_STAGE,onInit);
    }

    public function onInit(e:Event):Void
    {
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

        var jsonData:String = Assets.getText("assets/sxkCenter.json");
        var spineTextureAtals:SpineTextureAtlasLoader = new SpineTextureAtlasLoader("assets/sxkCenter.atlas",["assets/sxkCenter.png"]);
        spineTextureAtals.load(function(textureAtals:SpineTextureAtals):Void{
            // tilemap格式
            var tilemap:Tilemap = new Tilemap(stage.stageWidth,stage.stageHeight,textureAtals.loader.getTileset());
            for(i in 0...30)
            {
                var tilemapSprite = textureAtals.buildTilemapSkeleton("sxkCenter",jsonData);
                this.addChild(tilemap);
                tilemap.addTile(tilemapSprite);
                tilemapSprite.y = 200;
                tilemapSprite.x = Math.random()*stage.stageWidth;
                tilemapSprite.play("run");
                tilemapSprite.scaleX = 0.6;
                tilemapSprite.scaleY = 0.6;
            }
        },function(error:String):Void{
            trace("加载失败：",error);
        });

        var fps:openfl.display.FPS = new openfl.display.FPS();
        fps.textColor = 0xffffff;
        this.addChild(fps);

    }

}