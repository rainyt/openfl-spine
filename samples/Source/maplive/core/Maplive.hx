package maplive.core;


// import spine.openfl.BitmapDataTextureLoader;
// import spine.openfl.SkeletonAnimation;
// import spine.tilemap.BitmapDataTextureLoader;
// import spine.tilemap.SkeletonAnimation;
import spine.support.graphics.TextureAtlas;
import spine.SkeletonData;
import spine.SkeletonJson;
import spine.attachments.AtlasAttachmentLoader;
import openfl.display.Sprite;
import openfl.events.Event;

/**
 * 地图编辑器工具
 */
class Maplive extends Sprite{

    public function new(){
        super();
        this.addEventListener(Event.ADDED_TO_STAGE,onInit);
        // super(this.stage.stageWidth,this.stage.stageHeight,true);
    }

    public function onInit(e:Event):Void
    {
        stage.color = 0x002630;

        //Sprite渲染
        this.showSpirteSkeletonJson();

        //Tilemap渲染
        // this.showTilemapSkeletonJson();

        var fps:openfl.display.FPS = new openfl.display.FPS();
        fps.textColor = 0xffffff;
        this.addChild(fps);

    }

    public function showTilemapSkeletonJson():Void
    {
        var loader:spine.tilemap.BitmapDataTextureLoader = new spine.tilemap.BitmapDataTextureLoader(openfl.Assets.getBitmapData("assets/spineboy-pro.png"));
		var atlas:TextureAtlas = new TextureAtlas(openfl.Assets.getText("assets/spineboy-pro.atlas"),loader);
        var json:SkeletonJson = new SkeletonJson(new AtlasAttachmentLoader(atlas));
        json.setScale(0.6);
        
        var tilea:openfl.display.Tilemap  = new openfl.display.Tilemap(Std.int(stage.stageWidth),Std.int(stage.stageHeight),loader.getTileset());
        this.addChild(tilea);
        var skeletonData:SkeletonData = json.readSkeletonData(new spine.SkeletonDataFileHandle("assets/spineboy-pro.json"));
        for(i in 0...10)
        {
            var skeleton:spine.tilemap.SkeletonAnimation = new spine.tilemap.SkeletonAnimation(skeletonData);
            skeleton.x = Math.random()*stage.stageWidth;
            skeleton.y = 500;
            tilea.addTile(skeleton);
            skeleton.state.setAnimationByName(0,"walk",true);
        }
    }

    public function showSpirteSkeletonJson():Void
    {
        var loader:spine.openfl.BitmapDataTextureLoader = new spine.openfl.BitmapDataTextureLoader(openfl.Assets.getBitmapData("assets/spineboy-pro.png"));
		var atlas:TextureAtlas = new TextureAtlas(openfl.Assets.getText("assets/spineboy-pro.atlas"),loader);
        var json:SkeletonJson = new SkeletonJson(new AtlasAttachmentLoader(atlas));
        json.setScale(0.6);
        
        var skeletonData:SkeletonData = json.readSkeletonData(new spine.SkeletonDataFileHandle("assets/spineboy-pro.json"));
        for(i in 0...10)
        {
            var skeleton:spine.openfl.SkeletonAnimation = new spine.openfl.SkeletonAnimation(skeletonData);
            skeleton.x = Math.random()*stage.stageWidth;
            skeleton.y = 500;
            this.addChild(skeleton);
            skeleton.state.setAnimationByName(0,"walk",true);
        }
    }

}