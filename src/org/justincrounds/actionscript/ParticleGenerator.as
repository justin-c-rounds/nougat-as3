package org.justincrounds.actionscript {
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import caurina.transitions.*;
	public class ParticleGenerator extends MovieClip {
		public var controller:Controller;
		public var particle:String;
		public var lifespan:Number = 1;
		public var density:Number = 10;
		public var distance:Number = 100;
		public var startDegree:Number = 0;
		public var endDegree:Number = 360;
		public var faceDirection:Boolean = true;
		public var implode:Boolean = false;
		public var startScale:Number = 1;
		public var endScale:Number = 0;
		public var scaleJitter:Number = 0;
		public var distanceJitter:Number = 0;
		private var paused:Boolean = false;
		private var particleTimer:Timer;
		private var startX:Number;
		private var startY:Number;
		public function ParticleGenerator() {
			// particle generator. particles emit from single point. radiation constrained to angle determined by start & end, resulting in cloud and plume effects.
			addEventListener(Event.ADDED_TO_STAGE, addedToStage, false, 0, true);
		}
		public override function set x(value:Number):void {
			startX = value;
		}
		public override function set y(value:Number):void {
			startY = value;
		}
		private function addedToStage(event:Event) {
			controller.addEventListener("PAUSE", pauseHandler, false, 0, true);
			particleTimer = new Timer(1000/density);
			particleTimer.addEventListener("timer", timerHandler);
			particleTimer.start();
		}
		private function pauseHandler(event:BroadcastEvent) {
			paused = !paused;
			Tweener.pauseAllTweens();
			if (!paused) {
				Tweener.resumeAllTweens();
				particleTimer.start();
			} else {
				particleTimer.reset();
			}
		}
		private function timerHandler(event:TimerEvent) {
			if (!paused) {
				var range = endDegree - startDegree;
				var direction = startDegree + (range * Math.random());
				var ClassReference:Class = getDefinitionByName(particle) as Class;
				var instance:Object = new ClassReference();
				var emit = addChild(DisplayObject(instance));
				var scaleModifier = -scaleJitter + (Math.random() * ((startScale + scaleJitter) - (startScale - scaleJitter)));
				var distanceModifier = Math.random() * distance * distanceJitter;
				emit.scaleX = emit.scaleY = startScale + scaleModifier;
				emit.x = startX;
				emit.y = startY;
				if (faceDirection) {
					emit.rotation = direction;
				}
				if (implode) {
					emit.x = startX + (Math.sin(direction * (Math.PI / 180))) * distance;
					emit.y = startY + (Math.cos(direction * (Math.PI / 180))) * -distance;
					emit.alpha = 0;
					Tweener.addTween(emit, {
						alpha: 1,
						x: startX,
						y: startY,
						scaleX: endScale + scaleModifier,
						scaleY: endScale + scaleModifier,
						time: lifespan,
						onComplete: function() {
							this.parent.removeChild(this);
						}
					});
				} else {
					Tweener.addTween(emit, {
						alpha: 0,
						x: startX + (Math.sin(direction * (Math.PI / 180))) * (distance - distanceModifier),
						y: startY + (Math.cos(direction * (Math.PI / 180))) * -(distance - distanceModifier),
						scaleX: endScale + scaleModifier,
						scaleY: endScale + scaleModifier,
						time: lifespan,
						onComplete: function() {
							this.parent.removeChild(this);
						}
					});
				}
			}
		}
	}
}
