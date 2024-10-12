package ui;

import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.display.Sprite;

/**
 * 按钮
 */
class Button extends Sprite {
	public function new(text:String) {
		super();
		this.graphics.beginFill(0xd6d6d6);
		this.graphics.drawRoundRect(0, 0, 80, 32, 12, 12);
		this.graphics.endFill();

		var textField = new TextField();
		this.addChild(textField);
		textField.width = 80;
		textField.text = text;
		textField.setTextFormat(new TextFormat(null, 20, 0x0, null, null, null, null, null, CENTER));
        textField.mouseEnabled = false;
	}
}
