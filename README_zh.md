# openfl-spine
可在OpenFL引擎中渲染Spine动画的使用库，可通过Sprite、Tilemap实现渲染处理。
- OpenFL：https://github.com/openfl/openfl

# 各版本的定义说明
该版本兼容了3.8到4.2的Spine运行时版本，他们运行时关系请参考下述说明：
| Spine版本 | Spine运行时库 | 支持情况 | 定义 |
| --- | --- | --- | --- |
| 3.6 | spine-hx 3.6.0+ | Sprite + Tilemap渲染器 | / |
| 3.8 | spine-hx 3.8.0+ | Sprite + Tilemap渲染器 | spine3.8 |
| 4.0 | spine-hx 4.0+ | Sprite + Tilemap渲染器 | spine4 |
| 4.2 | spine-haxe git | Sprite渲染器 | spine4.2 |

# 依赖库（Dependent library）
- spine-hx：https://github.com/jeremyfa/spine-hx
    在3.6.0到4.0.0版本之间将使用spine-hx运行时进行渲染
- openfl-glsl：https://github.com/rainyt/openfl-glsl
    该库主要实现了SpineRenderShader着色器的支持，正因为有它，我才能轻松编写扩展SpriteSpine的着色器。
- spine-haxe：https://github.com/EsotericSoftware/spine-runtimes/tree/4.2/spine-haxe
    用于支持Spine4.2版本的官方Haxe运行时。

# 渲染器（Renderer）
- Tilemap渲染器：拥有极其快速渲染速度，但不支持网格。
- Sprite渲染器：拥有网格功能，单个精灵拥有批渲染功能，含有扩展功能，但是会消耗性能。

# 使用方法
通过命令行安装
```shell
haxelib install openfl-spine
```
> 如果使用Spine4.2版本，则需要安装Spine-Haxe-Git版本：[spine-haxe](https://github.com/EsotericSoftware/spine-runtimes/tree/4.2/spine-haxe)

在project.xml中配置
```xml
<!-- 可选参数：spine3.8 spine4 spine4.2 -->
<define name="spine4.2"/>
<haxelib name="openfl-spine"/>
```
并且在任意类中进行初始化
```haxe
SpineManager.init(this.stage);
```

# Sprite渲染器
使用Sprite渲染Spine对象，该渲染器支持以下功能：
- 1、遮罩
- 2、多纹理渲染
- 3、BlendMode支持（高亮叠加、乘法）
- 4、透明度支持

例子：
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
    trace("加载失败：",error);
});
```
      
# Tilemap渲染器
Tilemap需要一个tilemap进行装载，这意味着一样的图集的Spine只需要1次绘制。
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
在openfl-spine1.8.0版本开始，SpriteSpine可以被批处理。请注意，该功能暂不适用于Spine4.2以后的版本。
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

## 使用3.8
库当前默认是使用3.7版本，默认指向spine-hx3.6.0版本。如果需要使用3.8+版本，需要在库之前定义版本号：
```xml
<define name="spine3.8"/>
<haxelib name="openfl-spine"/>
```

## 使用4.0
如果需要使用Spine4.0版本，需要在库之前定义版本号：
```xml
<define name="spine4"/>
<haxelib name="openfl-spine"/>
```

## 使用4.2
使用Spine4.2版本，需要在库之前定义版本号：
```xml
<define name="spine4.2"/>
<haxelib name="openfl-spine"/>
```
> 当使用4.2版本时，将需要使用[spine-haxe](https://github.com/EsotericSoftware/spine-runtimes/tree/4.2/spine-haxe)运行时

## 常见问题
1. 当发生资源载入错误时，请检查Spine的版本是否一致，例如3.8的Spine文件不能在4.0中使用。
    - 这种情况需要确保所有Spine的资源版本都为一致。