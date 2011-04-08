package org.justincrounds.actionscript {
	import flash.events.*;
	import flash.text.*;
	import flash.utils.*;
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	public class TextDisplay extends Actor {
		protected var textField:TextField = new TextField();
		private var textFormat:TextFormat = new TextFormat();
		private var _textThickness:Number;
		private var _text:String;
		private var _font:Font;
		private var _color:String;
		private var _size:Number;
		private var _alignH:String;
		private var _wrap:Boolean;
		private var _letterSpacing:Number;
		private var _fieldWidth:Number;
		private var _fieldHeight:Number;
		private var _scrollRectWidth:Number;
		private var _scrollRectHeight:Number;
		public var selectable:Boolean = false;
		public var input:Boolean = false;
		public function TextDisplay() {
			//textField.autoSize = TextFieldAutoSize.LEFT;
			textField.antiAliasType = AntiAliasType.ADVANCED;
			textField.embedFonts = true;
			addChild(textField);
		}
		override public function init():void {
		}
		override public function set controller(c:Controller):void {
			super.controller = c;
			controller.addEventListener("UPDATE TEXT DISPLAY", updateTextDisplay, false, 0, true);
		}
		override public function set xml(d:XMLList):void {
			textField.htmlText = d.toString();
			super.xml = d;
		}
		override protected function addedToStage(e:Event):void {
			if (input) {
				textField.type = TextFieldType.INPUT;
				textField.addEventListener(Event.CHANGE, textInputHandler, false, 0, true);
			}
			textField.selectable = this.selectable;
			alignH = _alignH; // force realignment based on rendered pixel dimensions
			//textField.height = textField.textHeight;
			super.addedToStage(e);
		}
		override protected function removedFromStage(e:Event):void {
			controller.removeEventListener("UPDATE TEXT DISPLAY", updateTextDisplay);
			super.removedFromStage(e);
		}
		public function set letterSpacing(l:Number):void {
			_letterSpacing = l;
			textFormat.letterSpacing = _letterSpacing;
			textField.setTextFormat(textFormat);
		}
		public function set wrap(w:Boolean):void {
			_wrap = w;
			textField.wordWrap = w;
			if (w) {
				//textField.autoSize = TextFieldAutoSize.NONE;
				textField.multiline = true;
				textField.width = _fieldWidth;
				//textField.height = _fieldHeight;
				if (_xml != null) {
					textField.htmlText = _xml.toString();
				}
			}
		}
		public function set fieldWidth(n:Number):void {
			_fieldWidth = n;
			textField.width = _fieldWidth;
		}
		public function get fieldWidth():Number {
			return _fieldWidth;
		}
		public function set fieldHeight(n:Number):void {
			_fieldHeight = n;
			//textField.height = _fieldHeight;
		}
		public function get fieldHeight():Number {
			return textField.height;
		}
		public function set htmlText(s:String):void {
			textField.htmlText = s;
		}
		public function get htmlText():String {
			return textField.htmlText;
		}
		public function set alignH(alignH:String):void {
			_alignH = alignH;
			switch (_alignH) {
				case "left":
					textFormat.align = TextFormatAlign.LEFT;
					textField.autoSize = TextFieldAutoSize.LEFT;
					textField.x = 0;
					break;
				case "right":
					textFormat.align = TextFormatAlign.RIGHT;
					textField.autoSize = TextFieldAutoSize.LEFT;
					textField.x = -(textField.textWidth);
					break;
				case "center":
					textFormat.align = TextFormatAlign.CENTER;
					textField.autoSize = TextFieldAutoSize.CENTER;
					textField.x = isNaN(_fieldWidth) ? -(textField.textWidth * 0.5) : -(_fieldWidth * 0.5);
					break;
				case "justify":
					textFormat.align = TextFormatAlign.JUSTIFY;
					textField.x = 0;
					break;
			}
			textField.setTextFormat(textFormat);
		}
		public function set text(text:String):void {
			_text = text;
			textField.text = _text;
			textField.setTextFormat(textFormat);
			alignH = _alignH;
		}
		public function set scrollRectWidth(n:Number):void {
			_scrollRectWidth = n;
			if (_scrollRectHeight) {
				buildScrollRect();
			}
		}
		public function set scrollRectHeight(n:Number):void {
			_scrollRectHeight = n;
			if (_scrollRectWidth) {
				buildScrollRect();
			}
		}
		protected function textInputHandler(e:Event):void {
			controller.broadcast('TEXT INPUT CHANGED', {
				displayName: this.name,
				inputText: textField.text
			});
		}
		private function buildScrollRect():void {
			this.scrollRect = new Rectangle(0, 0, _scrollRectWidth, _scrollRectHeight);
		}
		public function get text():String {
			return textField.text;
		}
		public function set font(s:String):void {
			var fonts:Array = Font.enumerateFonts(false);
			for (var i:Number = 0; i < fonts.length; i++) {
				if (s == getQualifiedClassName(fonts[i]).split("_").pop()) {
					//var ClassReference:Class = getDefinitionByName(fonts[i]) as Class;
					//_font = new ClassReference();
					_font = fonts[i];
					textFormat.font = _font.fontName;
					textField.setTextFormat(textFormat);
					break;
				}
			}
		}
		public function set color(color:String):void {
			_color = "0x" + color.substring(1);
			textFormat.color = _color;
			textField.setTextFormat(textFormat);
		}
		public function set size(size:Number):void {
			_size = size;
			textFormat.size = _size;
			textField.setTextFormat(textFormat);
		}
		public function set fontWeight(fontWeight:String):void {
			switch (fontWeight) {
				case "bold":
					textFormat.bold = true;
					break;
			}
			textField.setTextFormat(textFormat);
		}
		public function set textThickness(textThickness:Number):void {
			_textThickness = textThickness;
			textField.thickness = _textThickness;
		}
		protected function updateTextDisplay(e:BroadcastEvent):void {
			e.object.displayName == this.name ? this.text = e.object.displayText : null;
		}
	}
}
