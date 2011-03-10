package org.justincrounds.actionscript {
	import caurina.transitions.*;
	import flash.display.*;
	public class Sequencer extends MovieClip {
		private var _controller:Controller;
		public var xml:XMLList;
		public function Sequencer() {
			this.stop();
		}
		public function set controller(c:Controller) {
			_controller = c;
			_controller.addEventListener("START SEQUENCE", startSequence, false, 0, true);
		}
		private function startSequence(e:BroadcastEvent) {
			if (e.object.toString() == this.name) {
				for each (var event in xml.child("event")) {
					for each (var tween in event.child("tween")) {
						var object = this.parent.getChildByName(tween.attribute("object").toString());
						if (tween.attribute("from").toString() != "") {
							object[tween.attribute("parameter").toString()] = Number(tween.attribute("from").toString());
						}
						var tweenObject = new Object();
						tweenObject[tween.attribute("parameter").toString()] = Number(tween.attribute("to").toString());
						tweenObject.time = Number(tween.attribute("duration").toString());
						tweenObject.delay = Number(event.attribute("time").toString());
						if (tween.attribute("transition").toString() != "") {
							tweenObject.transition = tween.attribute("transition").toString();
						} else {
							tweenObject.transition = "linear";
						}
						Tweener.addTween(object, tweenObject);
					}
					for each (var broadcast in event.child("broadcast")) {
						Tweener.addTween(this, {
							x: 0,
							time: 0,
							delay: Number(event.attribute("time").toString()),
							onComplete: function() {
								_controller.broadcast(broadcast.attribute("message").toString(), broadcast.attribute("data").toString());
							}
						});
					}
				}
			}
		}
	}
}
