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
该对象拥有批渲染高性能渲染，能够得到1draw的渲染。但是会有以下几个限制：
- 必须使用单张资源纹理渲染。
- 单张纹理资源大小不超过2048*2048。
- [注意] 使用批渲染渲染时，在openfl-spine1.6.0开始支持透明度，改色以及网格功能。

This object has high-performance batch rendering and can get 1draw rendering. But there will be the following restrictions:
- Must use single resource texture rendering.
- The size of a single texture resource does not exceed 2048*2048.
- [Note] When using batch rendering, the transparency, color change and grid functions are supported in openfl-spine1.6.0.

Demo：
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
            openflSprite.multipleTextureRender = true;
        },function(error:String):Void{
            trace("加载失败：",error);
        });
```
上面提及到必须使用单张图片纹理渲染，但也可以通过multipleTextureRender属性开启支持多纹理功能，但将会牺牲一定层度的性能：
As mentioned above, a single image texture must be used for rendering, but it is also possible to enable multi-texture support through the multipleTextureRender property, but a certain level of performance will be sacrificed:
```haxe
//功能能够通过multipleTextureRender属性开启，多张纹理图的渲染，必须开启这个属性，否则渲染会有异常。
spine.multipleTextureRender = true;
```
[注意] openfl-spine1.6.0开始将弃用`isNative`功能，因为从1.6.0开始，已经可以正常支持alpha/blendMode/颜色修改等功能；但如果仍然希望使用多纹理时，则需要使用`multipleTextureRender`。Openfl-spine 1.6.0 will deprecate the `isNative` function, because since 1.6.0, functions such as alpha/blendMode/color modification can be normally supported; but if you still want to use multiple textures, you need to use `multipleTextureRender`.
      
# Tilemap渲染器
Tilemap需要一个tilemap进行装载，这意味着一样的图集的Spine只需要1drawcall。Tilemap requires a tilemap to load, which means that Spine of the same atlas only needs 1 drawcall.

# Spine事件侦听器
侦听spine的原生事件，请使用（To listen to spine's native events, please use）：
```haxe
var event:AnimationEvent = new AnimationEvent();
var spine:SkeletonAnimation;
spine.state.addListener(event);
event.addEventListener(SpineEvent.COMPLETE,(event:SpineEvent)->{
    
});
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