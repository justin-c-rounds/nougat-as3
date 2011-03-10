package org.justincrounds.actionscript {
	import flash.display.MovieClip;
	public class Parallax extends MovieClip {
		private var _controller:Controller;
		public var ratio:Number = 2;
		public function Parallax() {
		}
		public function set controller(controller:Controller):void {
			_controller = controller;
			_controller.addEventListener("PARALLAX PAN", parallaxPan, false, 0, true);
		}
		private function parallaxPan(event:BroadcastEvent):void {
			var multiplier = 1;
			for (var i = numChildren - 1; i >= 0; i--) {
				var child = getChildAt(i);
				child.x += event.object.x * multiplier;
				child.y += event.object.y * multiplier;
				multiplier *= ratio;
			}
		}
	}
}
