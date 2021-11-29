package;

import spine.SkeletonJson;
import spine.SkeletonData;
import spine.Skeleton;
import spine.utils.SkeletonClipping;
import spine.attachments.AtlasAttachmentLoader;

class SkeletonClippingTest {
	static function main() {
		var skeletonData = new SkeletonData();
		var skeleton = new Skeleton(skeletonData);
		skeleton.updateWorldTransform();
		var clip = new SkeletonClipping();
        clip.getClippedTriangles
	}
}
