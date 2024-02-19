# 1.8.10
- 性能：改进对`spine-hx3.8.2`的创建Spine性能；

# 1.8.8
- 修复：修复`drakColor`的表现；
- 新增：新增`drakColor.a`透明度的支持；

# 1.8.4
- 删除：删除`shaderClass`的支持，请直接使用shader扩展。
- 删除：删除`getWidth`的内部实现。
- 修复：修复`填入黑色`的错误表现。

# 1.8.3
- 新增：新增TintBlack支持。
- 修复：修复事件无法正常移除的问题。
- 修复：修复剪辑遇到空骨架应预期结束。
- 新增：新增`CacheMode.GL_BITMAP`缓冲区位图缓存支持，但需要`zygameui`引擎库支持。
- 改进：改进`isCache`状态下的透明清除值默认为1。
- 弃用：不再支持`shaderClass`，如果需要更改shader，可以直接使用shader更改。
- 改进：改进`SpineRenderShader`着色器为唯一性，提高性能。

# 1.8.2
- 修复：修复SkeletonAnimation在stop后再调用play会无法继续播放动画的问题。
- 修复：修复BlendMode渲染异常的问题。
- 新增：新增Spine4的支持，当需要使用时，在openfl-spine之前定义：`<define name="spine4"/>`。

# 1.8.1
- 修复：修复在批渲染对象下渲染时，数据不会被缓存。

# 1.7.7
- 改进：改进SkeletonSpriteBatchs批处理功能。

# 1.7.4
- 新增：新增`SpriteSpine.isCache`缓存动画数据支持。但请注意，如果使用setMixByName等API，会影响缓存的正确帧；因此在使用setMixByName的情况下，应禁用`isCache`。

# 1.7.3
- 修复：修复自定义着色器没有正常更换的问题。
- 新增：新增`independent`的属性支持，可以让Spine单独不被`isLockFrameFps`影响。

# 1.7.2
- 改进：改进SpriteSpine的性能，减少了removeChild的调用。
- 新增：新增`SpriteSpine.shaderClass`自定义着色器支持。

# 1.7.1
- 新增：新增SpriteSpine的smoothing支持。

# 1.7.0
- 修复：修复`SpriteSpine`的C++渲染异常问题。

# 1.6.8
- 修复：修复遮罩会影响到其他`SpriteSpine`对象的问题。
- 修复：修复`SpriteSpine.isPlay`属性状态不正确的问题。
- 修复：修复`SpriteSpine`的BlendMode渲染错误的问题。

# 1.6.7
- 修复：修复`SpriteSpine`不支持透明度的问题。
- 修正：修复`SpineTextureAtlasLoader`错别字。
- 删除：删除`isNative`以及`multipleTextureRender`的渲染支持。
- 改进：`SpriteSpine`新增自动多纹理渲染支持。

# 1.6.3
- 新增：对`SpriteSpine`增加了遮罩支持。

# 1.6.0
- 弃用：不再支持`SpriteSpine`的`isNative`渲染支持，默认失效；如果仍然有需求，请参考`multipleTextureRender`多纹理渲染支持。
- 改进：新增了`SpineRenderShader`着色器，改进`SpriteSpine`渲染，目前已新增了透明度、BlendMode.ADD、颜色修改等支持（网格同时支持）。
- 依赖：需要依赖`openfl-glsl`库。

# 1.5.6
- 修复Tilemap的ScaleX/ScaleY渲染。
- 固定Spine默认版本为3.6.0，如需要使用3.8.1版本，需要库之前添加`<define name="spine3.8"/>`
- 新增了spine-hx3.8.1版本支持。

# 1.5.5
- 修复Tilemap的骨骼渲染问题。
- 改善颜色更改的性能。
- 新增对Tilemap的颜色更改支持。

# 1.5.4
- 新增按实际时间播放动画的支持，也可以通过`SpineManager.isLockFrameFps=true`来使用FPS播放，该值默认为false。
    - Added support for playing animations in real time. You can also use FPS playback with `SpineManager.isLockFrameFps=true`, which defaults to false.

# 1.5.3
- 优化了isNative=false时，透明=0的对象不显示。
	- When isNative=false is optimized, objects with transparency=0 are not displayed.

# 1.5.1
- 新增SpineManager管理器优化性能。
    - Added SpineManager Manager to optimize performance

# 1.5.0
- 新增SpineEvent事件支持。
	- Add spine events support.

# 1.4.9
- 为Tilemap渲染对象添加了colorTransform的支持
    - Add colorTransform support with Tilemap render. 
- 为本地添加了颜色更改支持。
    - Add colorTransform support with Native render.

# 1.4.8
- 修正SpineTextureAtlasLoader类名。
- 为`spine.openfl.SkeletonSprite`的`isNative=true`渲染添加了垃圾池处理。
- 优化`FRAME_ENTER`事件的添加与移除处理。

# 1.4.7
- 修复使用裁剪空白时产生的额外问题。

# 1.4.4
- 修复使用裁剪空白会导致渲染错误的问题。
- 兼容Spine-hx3.7.0版本。
