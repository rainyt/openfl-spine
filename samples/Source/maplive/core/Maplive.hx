package maplive.core;


import openfl.display.Tilemap;
import spine.SkeletonData;
import spine.SkeletonJson;
import spine.attachments.AtlasAttachmentLoader;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.BitmapData;
import openfl.utils.Assets;
import zygame.utils.load.SpineTextureAtalsLoader;

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
        stage.color = 0x002630;

        var jsonData:String = Assets.getText("assets/spineboy-pro.json");
        var spineTextureAtals:SpineTextureAtalsLoader = new SpineTextureAtalsLoader("assets/spineboy-pro.atlas",["assets/spineboy-pro.png"]);
        spineTextureAtals.load(function(textureAtals:SpineTextureAtals):Void{
            //Sprite格式
            var openflSprite = textureAtals.buildSpriteSkeleton("spineboy-pro",jsonData);
            this.addChild(openflSprite);
            openflSprite.y = 500;
            openflSprite.x = 500;
            openflSprite.play("walk");
            openflSprite.scaleX = 0.6;
            openflSprite.scaleY = 0.6;
            openflSprite.isNative = true;

            //tilemap格式
            // var tilemap:Tilemap = new Tilemap(stage.stageWidth,stage.stageHeight,textureAtals.loader.getTileset());
            // var tilemapSprite = textureAtals.buildTilemapSkeleton("spineboy-pro",jsonData);
            // this.addChild(tilemap);
            // tilemap.addTile(tilemapSprite);
            // tilemapSprite.y = 500;
            // tilemapSprite.x = 200;
            // tilemapSprite.play("walk");
            // tilemapSprite.scaleX = 0.6;
            // tilemapSprite.scaleY = 0.6;
        },function(error:String):Void{
            trace("加载失败：",error);
        });

        var fps:openfl.display.FPS = new openfl.display.FPS();
        fps.textColor = 0xffffff;
        this.addChild(fps);

    }

}