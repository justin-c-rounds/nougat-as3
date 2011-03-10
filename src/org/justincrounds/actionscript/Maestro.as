package org.justincrounds.actionscript {
	import caurina.transitions.*;
	import flash.media.*;
	import flash.utils.*;
	import flash.events.*;
	import flash.display.MovieClip;
	public class Maestro extends MovieClip {
		private var _controller:Controller;
		private var soundChannel:SoundChannel;
		private var sTransform:SoundTransform = new SoundTransform();
		private var _soundtrack;
		private var _tempo:Number = 0;
		public var dictionary:Dictionary = new Dictionary(true);
		private var currentTick:Number;
		private var currentBeat:Number;
		private var currentTime:Number = 0;
		private var tickInterval:Number;
		private var beatInterval:Number;
		public var loop:Boolean = false;
		private var currentPosition:Number = 0;
		private var isPaused:Boolean = false;
		private var newTempo:Number = 0;
		private var maestroTimer = new Timer(1);
		public function Maestro() {
			addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage, false, 0, true);
		}
		public function set controller(controller:Controller) {
			_controller = controller;
			_controller.addEventListener("MAESTRO START", maestroStart, false, 0, true);
			_controller.addEventListener("MAESTRO STOP", maestroStop, false, 0, true);
			_controller.addEventListener("MAESTRO TRACK", maestroTrack, false, 0, true);
			_controller.addEventListener("MAESTRO TEMPO", maestroTempo, false, 0, true);
			_controller.addEventListener("MAESTRO FADE IN", maestroFadeIn, false, 0, true);
			_controller.addEventListener("MAESTRO FADE OUT", maestroFadeOut, false, 0, true);
			_controller.addEventListener("MAESTRO END", maestroEnd, false, 0, true);
			_controller.addEventListener("PAUSE", pauseHandler, false, 0, true);
		}
		public function set soundtrack(soundtrack:String) {
			var ClassReference:Class = getDefinitionByName(soundtrack) as Class;
			_soundtrack = new ClassReference();
		}
		public function set tempo(tempo:Number) {
			_tempo = newTempo = tempo;
		}
		public function get tempo() {
			return _tempo;
		}
		public function set volume(volume:Number) {
			sTransform.volume = volume;
			soundChannel.soundTransform = sTransform;
		}
		public function get volume() {
			return sTransform.volume;
		}
		private function pauseHandler(event:BroadcastEvent) {
			if (!isPaused) {
				maestroStop();
			} else {
				maestroStart();
			}
			isPaused = !isPaused;
		}
		private function maestroStart(event:BroadcastEvent = null) {
			tempo = newTempo;
			soundChannel = _soundtrack.play(currentPosition, 0, sTransform);
			soundChannel.addEventListener(Event.SOUND_COMPLETE, soundComplete, false, 0, true);
			if (tempo != 0) {
				maestroTimer.addEventListener("timer", timerHandler);
				maestroTimer.start();
			}
		}
		private function maestroStop(event:BroadcastEvent = null) {
			currentPosition = soundChannel.position;
			soundChannel.stop();
			soundChannel.removeEventListener(Event.SOUND_COMPLETE, soundComplete);
			maestroTimer.removeEventListener("timer", timerHandler);
			maestroTimer.reset();
		}
		private function maestroTrack(event:BroadcastEvent) {
			soundtrack = event.object.toString();
		}
		private function maestroTempo(event:BroadcastEvent) {
			newTempo = Number(event.object.toString());
		}
		private function maestroFadeIn(event:BroadcastEvent) {
			maestroStart();
			volume = 0;
			Tweener.addTween(this, {
				volume: 1,
				time: Number(event.object)
			});
		}
		private function maestroFadeOut(event:BroadcastEvent) {
			Tweener.addTween(this, {
				volume: 0,
				time: Number(event.object),
				onCompleteScope: this,
				onComplete: function() {
					maestroStop();
				}
			});
		}
		private function maestroEnd(event:BroadcastEvent = null) {
			var key = (_tempo != 0) ? (currentTime - 1) + Math.ceil((_soundtrack.length - soundChannel.position) / ((60 / _tempo) * 1000)) : null;
			if (dictionary[key] == undefined) {
				dictionary[key] = "MAESTRO STOP";
			} else {
				dictionary[key] += ",MAESTRO STOP";
			}
		}
		private function soundComplete(event:Event) {
			soundChannel.removeEventListener(Event.SOUND_COMPLETE, soundComplete);
			if (loop) {
				currentPosition = 0;
				maestroStart();
			} else {
				maestroStop();
			}
		}
		private function processNoteEvent(currentTime:String) {
			if (dictionary[currentTime] != undefined) {
				for each (var currentEvents in dictionary[currentTime].split(",")) {
					var e = currentEvents.split("=");
					_controller.broadcast(e[0], e[1]);
				}
			}
		}
		private function timerHandler(event:TimerEvent) {
			var beat = Math.floor(soundChannel.position / ((60 / _tempo) * 1000));
			if (currentBeat != beat) {
				currentBeat = beat;
				_controller.broadcast("MAESTRO BEAT", currentBeat);
				_controller.broadcast("MAESTRO TIME", currentTime);
				processNoteEvent(currentTime.toString());
				currentTime++;
			}
			var tick = Math.floor(soundChannel.position / (((60 / _tempo) * 1000) / 60));
			if (currentTick != tick) {
				currentTick = tick % 60;
				_controller.broadcast("MAESTRO TICK", currentTick);
			}
		}
		private function removedFromStage(event:Event) {
			removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
			_controller.removeEventListener("MAESTRO START", maestroStart);
			_controller.removeEventListener("MAESTRO STOP", maestroStop);
			_controller.removeEventListener("MAESTRO TRACK", maestroTrack);
			_controller.removeEventListener("MAESTRO TEMPO", maestroTempo);
			_controller.removeEventListener("MAESTRO FADE IN", maestroFadeIn);
			_controller.removeEventListener("MAESTRO FADE OUT", maestroFadeOut);
			_controller.removeEventListener("MAESTRO END", maestroEnd);
			_controller.removeEventListener("PAUSE", pauseHandler);
		}
	}
}
