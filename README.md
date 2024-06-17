# V2.0.0
从2.0.0版本开始，将重构整个Spine的缓存机制，可能会产生一定的API变更。
1、为Spine新增一个高性能的缓存机制，注重提升性能。
2、删除GPU渲染模式，该模式不够完善，无法落实；

# openfl-spine
- 可在OpenFL引擎中渲染Spine动画的使用库，可通过Sprite、Tilemap实现渲染处理。
- The library can be used to render Spine animation in the OpenFL engine, and the rendering processing can be achieved through Sprite and Tilemap.
- OpenFL：https://github.com/openfl/openfl

# 依赖库（Dependent library）
- spine-hx：https://github.com/jeremyfa/spine-hx
    - 该库的Spine是使用了spine-hx，帮上不少的忙，openfl-spine仅实现了渲染器。The Spine of the library uses spine-hx, which helps a lot. Openfl-spine only implements the renderer.
- openfl-glsl：https://github.com/rainyt/openfl-glsl
    - 该库主要实现了SpineRenderShader着色器的支持，正因为有它，我才能轻松编写扩展SpriteSpine的着色器。This library mainly implements the support of the SpineRenderShader shader. Because of it, I can easily write shaders that extend SpriteSpine.

# 渲染器（Renderer）
- Tilemap渲染器：拥有极其快速渲染速度，但不支持网格。Tilemap renderer: Has extremely fast rendering speed, but does not support grids.
- Sprite渲染器：拥有网格功能，单个精灵拥有批渲染功能，含有扩展功能，但是会消耗性能。Sprite renderer: has a grid function, a single sprite has a batch rendering function, contains extended functions, but consumes performance.

# 使用方法
通过命令行安装（Install via command line）
```shell
haxelib install openfl-spine
```
在project.xml中配置（Configure in project.xml）
```xml
<haxelib name="openfl-spine"/>
```
并且在任意类中进行初始化（And initialize in any class）
```haxe
SpineManager.init(this.stage);
```

# Sprite渲染器（已提高了性能，内置批量渲染处理）
使用Sprite渲染Spine对象，使用SpriteSpine渲染已支持以下特性：
- 遮罩
- 多纹理渲染
- BlendMode支持
- 透明度支持
- 帧缓存（isCache）

Demo：
```haxe
        var jsonData:String = Assets.getText("assets/spineboy-pro.json");
        var spineTextureAtals:SpineTextureAtalsLoader = new SpineTextureAtalsLoader("assets/spineboy-pro.atlas",["assets/spineboy-pro.png"]);
        spineTextureAtals.load(function(textureAtals:SpineTextureAtals):Void{
            //Sprite格式
            var openflSprite = textureAtals.buildSpriteSkeleton("spineboy-pro",jsonData);
            openflSprite.isCache = true; // 可提高一定的性能，如果有多个相同的Spine的情况下
            this.addChild(openflSprite);
            openflSprite.y = 500;
            openflSprite.x = 500;
            openflSprite.play("walk");
            openflSprite.scaleX = 0.6;
            openflSprite.scaleY = 0.6;
        },function(error:String):Void{
            trace("加载失败：",error);
        });
```

[注意] 从openfl-spine1.6.4版本开始，将启用`isNative`以及`multipleTextureRender`的支持，使用SpriteSpine渲染时，将自动支持多纹理渲染。
      
# Tilemap渲染器
Tilemap需要一个tilemap进行装载，这意味着一样的图集的Spine只需要1drawcall。Tilemap requires a tilemap to load, which means that Spine of the same atlas only needs 1 drawcall.

# Spine事件侦听器
通用的动画事件侦听方法：
```haxe
var event:AnimationEvent = new AnimationEvent();
var spine:SkeletonAnimation;
spine.state.addListener(event);
event.addEventListener(SpineEvent.COMPLETE,(event:SpineEvent)->{
    
});
```
在SpriteSpine渲染对象下，可以直接侦听：
```haxe
var spine:SkeletonAnimation;
spine.addEventListener(SpineEvent.COMPLETE,(event:SpineEvent)->{
    
});
```
在openfl-spine1.8.0版本开始，SpriteSpine可以被批处理(Starting from version 1.8.0 of openfl-spine, SpriteSpine can be batch processed)：
```haxe
var batch:SkeletonSpriteBatchs = new SkeletonSpriteBatchs();
for(i in 0...100){
    var spine:SkeletonAnimation = buildSpine();
    this.addChild(spine);
    spine.x = Math.random() * 300;
    spine.y = Math.random() * 300;
}
```

# Spine工具
请注意，该库只单独支持3.7或者3.8版本；因Spine的数据结构不完全一致的问题会导致读取错误，请确认需要使用的Spine版本。
Please note that this library only supports version 3.7 or 3.8 separately; the incomplete data structure of Spine will cause reading errors. Please confirm the version of Spine you need to use.

## 使用3.8
库当前默认是使用3.7版本，默认指向spine-hx3.6.0版本。如果需要使用3.8+版本，需要在库之前定义版本号：
The library currently uses version 3.7 by default and points to version spine-hx3.6.0 by default. If you need to use version 3.8+, you need to define the version number before the library:
```xml
<define name="spine3.8"/>
<haxelib name="openfl-spine"/>
```

## 使用4.0
在2021年10月13日，开始支持Spine4.0，如果需要使用4.0，需要在库之前定义版本号：
On October 13, 2021, spine4.0 will be supported. If 4.0 needs to be used, the version number needs to be defined before the Library:
```xml
<define name="spine4"/>
<haxelib name="openfl-spine"/>
```

## 常见问题
1. 当发生资源载入错误时，请检查Spine的版本是否一致，例如3.8的Spine文件不能在4.0中使用。When a resource loading error occurs, please check whether the version of spine is consistent. For example, the spine file of 3.8 cannot be used in 4.0.
    - 这种情况需要确保所有Spine的资源版本都为一致。In this case, you need to ensure that the resource versions of all spines are consistent.