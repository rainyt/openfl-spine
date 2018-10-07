# OpenFLSpine
初次版本

# Spine-hx
该库的Spine是使用了spine-hx，帮上不少的忙，openfl-spine仅实现了渲染器。spine-hx来源：https://github.com/jeremyfa/spine-hx

# 该Spine提供了两个渲染器
Tilemap渲染器：拥有极其快速渲染速度，但不支持网格。
Sprite渲染器：拥有网格功能，单个精灵拥有批渲染功能。

# 使用方法
<haxelib name="openfl-spine"/>

# Sprite渲染器（已提高了性能，内置批量渲染处理）
        var loader:spine.openfl.BitmapDataTextureLoader = new spine.openfl.BitmapDataTextureLoader("assets/");
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
        
# Tilemap渲染器
Tilemap需要一个tilemap进行装载，这意味着一样的图集的Spine只需要1drawcall。
        
	var loader:spine.tilemap.BitmapDataTextureLoader = new spine.tilemap.BitmapDataTextureLoader("assets/");
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
