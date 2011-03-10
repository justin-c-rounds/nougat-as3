package {
	import org.justincrounds.actionscript.*;
	import caurina.transitions.*;
	import flash.events.*;
	public class Tooltip extends TextDisplay {
		//var bottomMargin:Number;
		private var _bgColor:String;
		public function Tooltip() {
			visible = false;
			//bottomMargin = this.height - this.scale9Grid.bottom;
			addEventListener(Event.ADDED_TO_STAGE, addedToStage, false, 0, true);
		}
		override public function set controller(c:Controller):void {
			super.controller = c;
			textField.background = true;
			textField.border = true;
			if (controller != null) {
				controller.addEventListener("show tooltip", showTooltip, false, 0, true);
				controller.addEventListener("hide tooltip", hideTooltip, false, 0, true);
			}
		}
		override protected function addedToStage(e:Event):void {
			if (controller != null) {
				controller.broadcast("hide tooltip");
			}
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove, false, 0, true);
		}
		override protected function removedFromStage(e:Event):void {
			controller.removeEventListener("show tooltip", showTooltip);
			controller.removeEventListener("hide tooltip", hideTooltip);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
			super.removedFromStage(e);
		}
		public function set bgColor(s:String):void {
			_bgColor = "0x" + s.substring(1);
			textField.backgroundColor = Number(_bgColor);
		}
		private function mouseMove(e:MouseEvent):void {
			x = e.stageX + 10;
			y = e.stageY + 10;
			if (x + this.width > controller.view.stageWidth) {
				x = e.stageX - this.width - 10;
			}
			if (y + this.height > controller.view.stageHeight) {
				y = e.stageY - this.height - 10;
			}
		}
		private function showTooltip(e:BroadcastEvent):void {
			if (e.object != null) {
				text = e.object as String;
				visible = true;
				//this.height = textField.height + this.scale9Grid.y + (bottomMargin * 2);
				//textField.scaleY = 1 / this.scaleY;
				Tweener.addTween(this, {
					alpha: 1,
					time: 0.25
				});
			}
		}
		private function hideTooltip(e:BroadcastEvent):void {
			Tweener.addTween(this, {
				alpha: 0,
				time: 0.25,
				onComplete: function():void {
					visible = false;
				}
			});
		}
	}
}
