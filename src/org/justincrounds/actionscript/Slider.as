package org.justincrounds.actionscript {
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	public class Slider extends Actor {
		public var assetSource:String;
		public var decrementerAsset:String;
		public var incrementerAsset:String;
		public var thumbAsset:String;
		public var trackAsset:String;
		public var trackStart:Number;
		public var trackLength:Number;
		public var thumbSize:Number;
		public var stepSize:Number;
		public var minimumValue:Number;
		public var maximumValue:Number;
		public var orientation:String;
		public var action:String;
		public var currentValue:Number;
		private var incrementerButton:Sprite;
		private var decrementerButton:Sprite;
		private var thumb:Sprite;
		private var thumbDown:Boolean = false;
		public function Slider() {
		}
		override public function init():void {
			if (this.assetSource == "zip") {
				var trackZipAssetLoader:ZipAssetLoader = new ZipAssetLoader();
				trackZipAssetLoader.controller = this.controller;
				trackZipAssetLoader.asset = this.trackAsset;
				addChild(trackZipAssetLoader);
				var decrementerZipAssetLoader:ZipAssetLoader = new ZipAssetLoader();
				decrementerZipAssetLoader.controller = this.controller;
				decrementerZipAssetLoader.asset = this.decrementerAsset;
				decrementerZipAssetLoader.y = this.orientation == 'vertical' ? this.trackStart + this.trackLength : 0;
				decrementerButton = addChild(decrementerZipAssetLoader) as Sprite;
				var incrementerZipAssetLoader:ZipAssetLoader = new ZipAssetLoader();
				incrementerZipAssetLoader.controller = this.controller;
				incrementerZipAssetLoader.asset = this.incrementerAsset;
				incrementerZipAssetLoader.x = this.orientation == 'horizontal' ? this.trackStart + this.trackLength : 0;
				incrementerButton = addChild(incrementerZipAssetLoader) as Sprite;
				var thumbZipAssetLoader:ZipAssetLoader = new ZipAssetLoader();
				thumbZipAssetLoader.controller = this.controller;
				thumbZipAssetLoader.asset = this.thumbAsset;
				thumbZipAssetLoader.x = this.orientation == 'horizontal' ? this.trackStart : 0;
				thumbZipAssetLoader.y = this.orientation == 'vertical' ? this.trackStart : 0;
				thumb = addChild(thumbZipAssetLoader) as Sprite;
			} else if (assetSource == 'url') {
				var trackAssetLoader:AssetLoader = new AssetLoader();
				trackAssetLoader.url = this.trackAsset;
				addChild(trackAssetLoader);
				var decrementerAssetLoader:AssetLoader = new AssetLoader();
				decrementerAssetLoader.url = this.decrementerAsset;
				decrementerAssetLoader.y = this.orientation == 'vertical' ? this.trackStart + this.trackLength : 0;
				this.decrementerButton = addChild(decrementerAssetLoader) as Sprite;
				var incrementerAssetLoader:AssetLoader = new AssetLoader();
				incrementerAssetLoader.url = this.incrementerAsset;
				incrementerAssetLoader.x = this.orientation == 'horizontal' ? this.trackStart + this.trackLength : 0;
				this.incrementerButton = addChild(incrementerAssetLoader) as Sprite;
				var thumbAssetLoader:AssetLoader = new AssetLoader();
				thumbAssetLoader.url = this.thumbAsset;
				thumbAssetLoader.x = this.orientation == 'horizontal' ? this.trackStart : 0;
				thumbAssetLoader.y = this.orientation == 'vertical' ? this.trackStart : 0;
				this.thumb = addChild(thumbAssetLoader) as Sprite;
			}
			this.incrementerButton.buttonMode = true;
			this.incrementerButton.addEventListener(MouseEvent.CLICK, increment, false, 0, true);
			this.decrementerButton.buttonMode = true;
			this.decrementerButton.addEventListener(MouseEvent.CLICK, decrement, false, 0, true);
			this.thumb.buttonMode = true;
			this.thumb.addEventListener(MouseEvent.MOUSE_DOWN, thumbOn, false, 0, true);
		}
		override public function set controller(c:Controller):void {
			super.controller = c;
			controller.addEventListener('ENABLE BUTTONS', enableButtons, false, 0, true);
			controller.addEventListener('DISABLE BUTTONS', disableButtons, false, 0, true);
		}
		override protected function addedToStage(e:Event):void {
			parent.addEventListener(MouseEvent.MOUSE_MOVE, thumbMove, false, 0, true);
			parent.addEventListener(MouseEvent.MOUSE_UP, thumbOff, false, 0, true);
			super.addedToStage(e);
		}
		override protected function removedFromStage(e:Event):void {
			controller.removeEventListener('ENABLE BUTTONS', enableButtons);
			controller.removeEventListener('DISABLE BUTTONS', disableButtons);
			this.incrementerButton.removeEventListener(MouseEvent.CLICK, increment);
			this.decrementerButton.removeEventListener(MouseEvent.CLICK, decrement);
			this.thumb.removeEventListener(MouseEvent.MOUSE_DOWN, thumbOn);
			parent.removeEventListener(MouseEvent.MOUSE_UP, thumbOff);
			parent.removeEventListener(MouseEvent.MOUSE_MOVE, thumbMove);
			super.removedFromStage(e);
		}
		private function increment(e:MouseEvent):void {
			this.currentValue = this.currentValue + this.stepSize < this.maximumValue ? this.currentValue + this.stepSize : this.maximumValue;
			update();
		}
		private function decrement(e:MouseEvent):void {
			this.currentValue = this.currentValue - this.stepSize > this.minimumValue ? this.currentValue - this.stepSize : this.minimumValue;
			update();
		}
		protected function update():void {
			this.currentValue = Math.round(this.currentValue / this.stepSize) * this.stepSize;
			if (this.orientation == 'horizontal') {
				this.thumb.x = ((this.currentValue - this.minimumValue) * ((this.trackLength - this.thumbSize) / (this.maximumValue - this.minimumValue))) + this.trackStart;
			} else if (this.orientation == 'vertical') {
				this.thumb.y = ((this.currentValue - this.minimumValue) * ((this.trackLength - this.thumbSize) / (this.maximumValue - this.minimumValue))) + this.trackStart;
			}
			this.controller.broadcast(this.action, this.currentValue); 
		}
		private function thumbOn(e:MouseEvent):void {
			this.thumbDown = true;
		}
		private function thumbOff(e:MouseEvent):void {
			this.thumbDown = false;
		}
		private function thumbMove(e:MouseEvent):void {
			if (this.thumbDown) {
				if (orientation == "horizontal") {
					this.currentValue = ((globalToLocal(new Point(e.stageX, e.stageY)).x - (this.thumbSize * 0.5)) - this.trackStart) * ((this.maximumValue - this.minimumValue)/(this.trackLength - this.thumbSize)) + this.minimumValue;
				} else if (orientation == "vertical") {
					this.currentValue = ((globalToLocal(new Point(e.stageX, e.stageY)).y - (this.thumbSize * 0.5)) - this.trackStart) * ((this.maximumValue - this.minimumValue)/(this.trackLength - this.thumbSize)) + this.minimumValue;
				}
				if (this.currentValue < this.minimumValue) {
					this.currentValue = this.minimumValue;
				} else if (this.currentValue > this.maximumValue) {
					this.currentValue = this.maximumValue;
				}
				this.currentValue = Math.round(this.currentValue / this.stepSize) * this.stepSize;
				update();
			}
		}
		private function enableButtons(e:BroadcastEvent):void {
			this.alpha = 1;
			this.mouseEnabled = true;
		}
		private function disableButtons(e:BroadcastEvent):void {
			this.alpha = 0.5;
			this.mouseEnabled = false;
		}
	}
}
