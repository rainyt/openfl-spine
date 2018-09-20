package maplive.core;


import spine.openfl.BitmapDataTextureLoader;
import spine.openfl.SkeletonAnimation;
// import spine.tilemap.BitmapDataTextureLoader;
// import spine.tilemap.SkeletonAnimation;
import spine.support.graphics.TextureAtlas;
import spine.SkeletonData;
import spine.SkeletonJson;
import spine.attachments.AtlasAttachmentLoader;
import spine.AnimationStateData;
import spine.AnimationState;
import openfl.display.Sprite;
import openfl.events.Event;

/**
 * 地图编辑器工具
 */
class Maplive extends Sprite{

    private var _as:Array<SkeletonAnimation> = [];

    public function new(){
        super();
        this.addEventListener(Event.ADDED_TO_STAGE,onInit);
        this.addEventListener(Event.ENTER_FRAME,onFrame);
        // super(this.stage.stageWidth,this.stage.stageHeight,true);
    }

    public function onInit(e:Event):Void
    {
        stage.color = 0x002630;

        doEvent();

        var fps:openfl.display.FPS = new openfl.display.FPS();
        fps.textColor = 0xffffff;
        this.addChild(fps);

    }

    private var _a:SkeletonAnimation;

    public function doEvent():Void
    {

        var loader:BitmapDataTextureLoader = new BitmapDataTextureLoader("assets/");
		var atlas:TextureAtlas = new TextureAtlas(openfl.Assets.getText("assets/spineboy-pro.atlas"),loader);
        var json:SkeletonJson = new SkeletonJson(new AtlasAttachmentLoader(atlas));
        json.setScale(0.6);
        
        var skeletonData:SkeletonData = json.readSkeletonData(new SkeletonDataFileHandle("assets/spineboy-pro.json"));
        // var tilea:openfl.display.Tilemap  = new openfl.display.Tilemap(Std.int(getStageWidth()),Std.int(getStageHeight()),loader.getTileset());
        for(i in 0...10)
        {
            var skeleton:SkeletonAnimation = new SkeletonAnimation(skeletonData);
            skeleton.x = Math.random()*stage.stageWidth;
            skeleton.y = 500;
            // tilea.addTile(skeleton);
            // this.addChild(tilea);
            this.addChild(skeleton);
            // skeleton.scaleX = 3;
            // skeleton.scaleY = 3;
            _a = skeleton;
            _as.push(skeleton);
            _a.state.setAnimationByName(0,"walk",true);
            _a.advanceTime(1/60);
        }
        // trace(skeletonData.getAnimations()[2].name);
    }

     public function onFrame(e:Event):Void
    {
        // trace("draw!");
        if(_a != null){
            for(i in 0..._as.length)
            {
                _as[i].advanceTime(1/60);
            }
           
            // _a.skeleton.updateWorldTransform();
            // _a.update();
        }
            // _a.advanceTime(1/60);
    }

}