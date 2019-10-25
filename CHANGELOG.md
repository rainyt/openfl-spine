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
