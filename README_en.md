# openfl-spine
A library for rendering Spine animations in the OpenFL engine, which can be achieved through Sprite and Tilemap for rendering processing.
- OpenFL：https://github.com/openfl/openfl

# Definition and Explanation of Each Version
This version is compatible with Spine runtime versions 3.8 to 4.2. Please refer to the following instructions for their runtime relationships:
| Spine version | Runtime | Support | Define |
| --- | --- | --- | --- |
| 3.6 | spine-hx 3.6.0+ | Sprite + Tilemap render | / |
| 3.8 | spine-hx 3.8.0+ | Sprite + Tilemap render | spine3.8 |
| 4.0 | spine-hx 4.0+ | Sprite + Tilemap render | spine4 |
| 4.2 | spine-haxe git | Sprite render | spine4.2 |

# Dependent library
- spine-hx：https://github.com/jeremyfa/spine-hx
    The spine hx runtime will be used for rendering between versions 3.6.0 and 4.0.0
- openfl-glsl：https://github.com/rainyt/openfl-glsl
    This library mainly implements support for SpineEnderShader shaders, which makes it easy for me to write shaders that extend SpriteSpine.
- spine-haxe：https://github.com/EsotericSoftware/spine-runtimes/tree/4.2/spine-haxe
    Used to support the official Haxe runtime for Spine 4.2 version.

# Renderer
- Tilemap render: Has extremely fast rendering speed, but does not support meshes.
- Sprite render: Having grid function, a single sprite has batch rendering function and expansion function, but it will consume performance.

# Use
Install through command line:
```shell
haxelib install openfl-spine
```
> 如果使用Spine4.2版本，则需要安装Spine-Haxe-Git版本：[spine-haxe](https://github.com/EsotericSoftware/spine-runtimes/tree/4.2/spine-haxe)

Configure in project.xml
```xml
<!-- opt param：spine3.8 spine4 spine4.2 -->
<define name="spine4.2"/>
<haxelib name="openfl-spine"/>
```
And initialize in any class
```haxe
SpineManager.init(this.stage);
```

# Sprite Render
Use Sprite to render Spine objects, which supports the following features:
- 1. Mask
- 2. Multi texture rendering
- 3. BlendMode supports (highlight overlay, multiplication)
- 4. Transparency support

Demo:
```haxe
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
},function(error:String):Void{
    trace("Load fail",error);
});
```
      
# Tilemap Render
Tilemap requires a tilemap for loading, which means that Spine for the same atlas only needs to be drawn once.

# Spine Event Listener
General animation event listening method:
```haxe
var event:AnimationEvent = new AnimationEvent();
var spine:SkeletonAnimation;
spine.state.addListener(event);
event.addEventListener(SpineEvent.COMPLETE,(event:SpineEvent)->{
    
});
```
Under SpriteSpine rendering objects, you can directly listen to:
```haxe
var spine:SkeletonAnimation;
spine.addEventListener(SpineEvent.COMPLETE,(event:SpineEvent)->{
    
});
```
Starting from version 1.8.0 of openfl-spine, SpriteSpine can be batch processed. Please note that this feature is currently not available for versions after Spine 4.2.
```haxe
var batch:SkeletonSpriteBatchs = new SkeletonSpriteBatchs();
for(i in 0...100){
    var spine:SkeletonAnimation = buildSpine();
    this.addChild(spine);
    spine.x = Math.random() * 300;
    spine.y = Math.random() * 300;
}
```

# Spine Tools
Please note that this library only supports version 3.7 or 3.8 separately; Due to the issue of inconsistent data structures in Spine, reading errors may occur. Please confirm the version of Spine that needs to be used.

> When using version 4.2, it will be necessary to use [spine-haxe](https://github.com/EsotericSoftware/spine-runtimes/tree/4.2/spine-haxe)

## FAQ
1. When a resource loading error occurs, please check if the version of Spine is consistent, for example, Spine files with version 3.8 cannot be used in version 4.0.
- This situation requires ensuring that all Spine resource versions are consistent.