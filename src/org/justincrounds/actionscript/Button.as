package org.justincrounds.actionscript {
	import flash.events.*;
	public class Button extends Actor {
		public var action:String;
		public var param:Object;
		public var tooltip:String;
		public function Button() {
			buttonMode = true;
			mouseChildren = false;
		}
		override public function set controller(c:Controller):void {
			super.controller = c;
			addEventListener(MouseEvent.CLICK, click, false, 0, true);
			addEventListener(MouseEvent.MOUSE_OVER, mouseOver, false, 0, true);
			addEventListener(MouseEvent.MOUSE_OUT, mouseOut, false, 0, true);
			controller.addEventListener("DISABLE BUTTONS", disableButton, false, 0, true);
			controller.addEventListener("ENABLE BUTTONS", enableButton, false, 0, true);
			controller.addEventListener("DISABLE BUTTON", disableButton, false, 0, true);
			controller.addEventListener("ENABLE BUTTON", enableButton, false, 0, true);
			controller.addEventListener("DEACTIVATE BUTTONS", deactivateButton, false, 0, true);
			controller.addEventListener("ACTIVATE BUTTONS", activateButton, false, 0, true);
			controller.addEventListener("DEACTIVATE BUTTON", deactivateButton, false, 0, true);
			controller.addEventListener("ACTIVATE BUTTON", activateButton, false, 0, true);
		}
		override protected function removedFromStage(e:Event):void {
			removeEventListener(MouseEvent.CLICK, click);
			removeEventListener(MouseEvent.MOUSE_OVER, mouseOver);
			removeEventListener(MouseEvent.MOUSE_OUT, mouseOut);
			controller.removeEventListener("DISABLE BUTTONS", disableButton);
			controller.removeEventListener("ENABLE BUTTONS", enableButton);
			controller.removeEventListener("DISABLE BUTTON", disableButton);
			controller.removeEventListener("ENABLE BUTTON", enableButton);
			controller.removeEventListener("DEACTIVATE BUTTONS", deactivateButton);
			controller.removeEventListener("ACTIVATE BUTTONS", activateButton);
			controller.removeEventListener("DEACTIVATE BUTTON", deactivateButton);
			controller.removeEventListener("ACTIVATE BUTTON", activateButton);
			super.removedFromStage(e);
		}
		override public function set mouseEnabled(value:Boolean):void {
			if (value) {
				alpha = 1;
				addEventListener(MouseEvent.CLICK, click, false, 0, true);
				addEventListener(MouseEvent.MOUSE_OVER, mouseOver, false, 0, true);
				addEventListener(MouseEvent.MOUSE_OUT, mouseOut, false, 0, true);
			} else {
				alpha = 0.5;
				removeEventListener(MouseEvent.CLICK, click);
				removeEventListener(MouseEvent.MOUSE_OVER, mouseOver);
				removeEventListener(MouseEvent.MOUSE_OUT, mouseOut);
				if (controller != null) {
					controller.broadcast("hide tooltip");
				}
			}
			this.buttonMode = value;
			super.mouseEnabled = value;
		}
		protected function click(e:MouseEvent):void {
			if(this.action != null) {
				controller.broadcast(this.action, this.param);
				dispatchEvent(new BroadcastEvent(this.action, this.param));
			}
		}
		protected function mouseOver(event:MouseEvent):void {
			controller.broadcast("show tooltip", this.tooltip);
		}
		protected function mouseOut(event:MouseEvent):void {
			controller.broadcast("hide tooltip");
		}
		protected function disableButton(e:BroadcastEvent):void {
			if (e.type == "DISABLE BUTTONS" || (e.type == "DISABLE BUTTON" && e.object == this.name)) {
				this.mouseEnabled = false;
			}
		}
		protected function enableButton(e:BroadcastEvent):void {
			if (e.type == "ENABLE BUTTONS" || (e.type == "ENABLE BUTTON" && e.object == this.name)) {
				this.mouseEnabled = true;
			}
		}
		protected function deactivateButton(e:BroadcastEvent):void {
			if (e.type == "DEACTIVATE BUTTONS" || (e.type == "DEACTIVATE BUTTON" && e.object == this.name)) {
				//
			}
		}
		protected function activateButton(e:BroadcastEvent):void {
			if (e.type == "ACTIVATE BUTTONS" || (e.type == "ACTIVATE BUTTON" && e.object == this.name)) {
				//
			}
		}
	}
}
