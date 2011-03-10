package org.justincrounds.actionscript {
	import flash.media.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.display.MovieClip;
	public class Sampler extends MovieClip {
		private var _controller:Controller;
		private var dictionary:Dictionary;
		private var isPaused:Boolean = false;
		private var soundIndex:Number = 0;
		public function Sampler() {
			addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage, false, 0, true);
		}
		public function set controller(controller:Controller) {
			_controller = controller;
			_controller.addEventListener("SAMPLER PLAY", samplerPlay, false, 0, true);
			_controller.addEventListener("PAUSE", pauseHandler, false, 0, true);
		}
		private function samplerPlay(event:BroadcastEvent) {
			var ClassReference:Class = getDefinitionByName(event.object.toString()) as Class;
			var sound = new ClassReference();
			var soundChannel = sound.play();
		}
		private function pauseHandler(event:BroadcastEvent) {
			// need to create method for pausing/resuming all currently playing sounds?
			// try creating an Audio object class that responds to pause commands!
		}
		private function removedFromStage(event:Event) {
			removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
			_controller.removeEventListener("SAMPLER PLAY", samplerPlay);
			_controller.removeEventListener("PAUSE", pauseHandler);
		}
	}
}
