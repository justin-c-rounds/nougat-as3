package org.justincrounds.actionscript {
	import caurina.transitions.*;
	import flash.display.*;
	import flash.events.*;
	public class Sequencer extends Actor {
		public var autoStart:Boolean;
		public function Sequencer() {
		}
		override public function init():void {
			autoStart ? controller.broadcast('START SEQUENCE', this.name) : null;
		}
		override public function set controller(c:Controller):void {
			super.controller = c;
			controller.addEventListener('START SEQUENCE', startSequence, false, 0, true);
		}
		override protected function removedFromStage(e:Event):void {
			controller.removeEventListener('START SEQUENCE', startSequence);
			super.removedFromStage(e);
		}
		private function startSequence(e:BroadcastEvent):void {
			if (e.object.toString() == this.name) {
				for each (var event:XML in xml.child('event')) {
					for each (var tween:XML in event.child('tween')) {
						var actor:Actor = this.parent.getChildByName(tween.attribute('actor').toString()) as Actor;
						if (tween.attribute('from').toString() != '') {
							actor[tween.attribute('parameter').toString()] = Number(tween.attribute('from').toString());
						}
						var tweenObject:Object = new Object();
						tweenObject[tween.attribute('parameter').toString()] = Number(tween.attribute('to').toString());
						tweenObject.time = Number(tween.attribute('duration').toString());
						tweenObject.delay = Number(event.attribute('time').toString());
						if (tween.attribute('transition').toString() != '') {
							tweenObject.transition = tween.attribute('transition').toString();
						} else {
							tweenObject.transition = 'linear';
						}
						Tweener.addTween(actor, tweenObject);
					}
					for each (var broadcast:XML in event.child('broadcast')) {
						Tweener.addTween(this, {
							x: 0,
							time: 0,
							delay: Number(event.attribute('time').toString()),
							onComplete: function():void {
								controller.broadcast(broadcast.attribute('message').toString(), broadcast.attribute('data').toString());
							}
						});
					}
				}
			}
		}
	}
}
