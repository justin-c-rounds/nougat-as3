package org.justincrounds.actionscript {
	import flash.media.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.display.MovieClip;
	public class Sampler extends Actor {
		private var isPaused:Boolean = false;
		private var soundIndex:Number = 0;
		public function Sampler() {
		}
		override public function set controller(c:Controller):void {
			super.controller = c;
			controller.addEventListener('SAMPLER PLAY', samplerPlay, false, 0, true);
			controller.addEventListener('PAUSE', pauseHandler, false, 0, true);
		}
		override protected function removedFromStage(e:Event):void {
			controller.removeEventListener('SAMPLER PLAY', samplerPlay);
			controller.removeEventListener('PAUSE', pauseHandler);
		}
		private function samplerPlay(event:BroadcastEvent) {
			//var ClassReference:Class = getDefinitionByName(event.object.toString()) as Class;
			var sound = controller.model.dictionary[event.object.toString()];
			var soundChannel = sound.play();
		}
		private function pauseHandler(event:BroadcastEvent) {
			// need to create method for pausing/resuming all currently playing sounds?
			// try creating an Audio object class that responds to pause commands!
		}
	}
}
