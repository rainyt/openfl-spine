# openfl-spine
可在OpenFL引擎中渲染Spine动画的使用库，可通过Sprite、Tilemap实现渲染处理。OpenFL来源：https://github.com/openfl/openfl

# spine-hx
该库的Spine是使用了spine-hx，帮上不少的忙，openfl-spine仅实现了渲染器。spine-hx来源：https://github.com/jeremyfa/spine-hx

# 该Spine提供了两个渲染器
Tilemap渲染器：拥有极其快速渲染速度，但不支持网格。
Sprite渲染器：拥有网格功能，单个精灵拥有批渲染功能，含有扩展功能，但是会消耗性能。

# 使用方法
通过命令行安装
```shell
haxelib install openfl-spine
```
在project.xml中配置
```xml
<haxelib name="openfl-spine"/>
```

# Sprite渲染器（已提高了性能，内置批量渲染处理）
该对象拥有批渲染高性能渲染，能够得到1draw的渲染。但是会有以下几个限制：
- 必须使用单张资源纹理渲染。
- 单张纹理资源大小不超过2048*2048。
- 使用批渲染渲染时，暂时不支持透明度，改色等功能；但是支持网格功能。

创建示例：
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
            openflSprite.isNative = true;
        },function(error:String):Void{
            trace("加载失败：",error);
        });
```
上面提及到必须使用单张图片纹理渲染，但也可以通过isNative属性开启支持多纹理、透明度、改色等功能，但将会牺牲一定层度的性能：
```haxe
//功能能够通过isNative属性开启，多张纹理图的渲染，必须开启这个属性，否则渲染会有异常。
spine.isNative = true;
```
      
# Tilemap渲染器
Tilemap需要一个tilemap进行装载，这意味着一样的图集的Spine只需要1drawcall。
