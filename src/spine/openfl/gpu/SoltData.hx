package spine.openfl.gpu;

import spine.support.graphics.TextureAtlas.AtlasRegion;
import openfl.display.BitmapData;
import spine.attachments.RegionAttachment;

/**
 * 骨架姿势数据
 */
class SoltData {
	/**
	 * 绘制节点
	 */
	public var slot:Slot;

	/**
	 * 顶点数据
	 */
	public var vertices:Array<Float>;

	/**
	 * UV数据
	 */
	public var uvs:Array<Float>;

	/**
	 * 顶点索引
	 */
	public var triangles:Array<Int>;

	/**
	 * 位图
	 */
	public var bitmapData:BitmapData;

	public function new(slot:Slot) {
		this.slot = slot;
		if (Std.isOfType(slot.attachment, RegionAttachment)) {
			vertices = [];
			var region:RegionAttachment = cast slot.attachment;
			var atlas:AtlasRegion = cast region.getRegion();
			var offest = region.getOffset();
			vertices.push(offest[6]);
			vertices.push(offest[7]);
			vertices.push(offest[0]);
			vertices.push(offest[1]);
			vertices.push(offest[2]);
			vertices.push(offest[3]);
			vertices.push(offest[4]);
			vertices.push(offest[5]);
			

			trace("vertices=", region.name, vertices);

			// region.computeWorldVertices(slot.bone, vertices, 0, 2);
			uvs = region.getUVs();
			triangles = [];
			// triangles[0] = 0;
			// triangles[1] = 1;
			// triangles[2] = 2;
			// triangles[3] = 2;
			// triangles[4] = 3;
			// triangles[5] = 0;

			triangles[0] = 0;
			triangles[1] = 1;
			triangles[2] = 2;
			triangles[3] = 2;
			triangles[4] = 3;
			triangles[5] = 0;
			bitmapData = cast(region.getRegion(), AtlasRegion).page.rendererObject;
		}
		if (vertices != null && vertices.length == 0)
			vertices = null;
	}
}
