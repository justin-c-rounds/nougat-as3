package org.justincrounds.actionscript {
	import flash.media.*;
	import flash.net.URLRequest;
	import caurina.transitions.properties.SoundShortcuts;
	import caurina.transitions.*;
	public class Jukebox extends Actor {
		private var soundChannel:SoundChannel;
		public var loop:Boolean = false;
		private var _soundtrack:String;
		private var tracks:Array;
		public var mode:String = "play all";
		public function Jukebox() {
			SoundShortcuts.init();
		}
		public function set soundtrack(s:String) {
			_soundtrack = s;
			tracks = _soundtrack.split(",");
		}
		public function get soundtrack():String {
			return _soundtrack;
		}
		override public function set controller(c:Controller):void {
			super.controller = c;
			controller.addEventListener("JUKEBOX PLAY", jukeboxPlay, false, 0, true);
			controller.addEventListener("JUKEBOX PAUSE", jukeboxPause, false, 0, true);
			controller.addEventListener("JUKEBOX STOP", jukeboxStop, false, 0, true);
		}
		override private function removedFromStage(e:Event):void {
			controller.removeEventListener("JUKEBOX PLAY", jukeboxPlay);
			controller.removeEventListener("JUKEBOX PAUSE", jukeboxPause);
			controller.removeEventListener("JUKEBOX STOP", jukeboxStop);
			super.removedFromStage(e);
		}
		private function jukeboxPlay(e:BroadcastEvent):void {
			switch (mode) {
				case "play all":
					break;
				case "random":
					var ClassReference:Class = getDefinitionByName(tracks[Math.round(Math.random() * tracks.length)]) as Class;
					var sound:Sound = new ClassReference() as Sound;
					var soundChannel = sound.play();
					break;
				case "shuffle":
					break;
			}
		}
		private function jukeboxPause(e:BroadcastEvent):void {
		}
		private function jukeboxStop(e:BroadcastEvent):void {
		}
		public function raiseVolume() {
			Tweener.addTween(soundAChannel, {
				_sound_volume: 1,
				time: 4,
				transition: "easeInOutQuad"
			});
			Tweener.addTween(soundBChannel, {
				_sound_volume: 1,
				time: 4,
				transition: "easeInOutQuad"
			});
		}
		public function lowerVolume() {
			Tweener.addTween(soundAChannel, {
				_sound_volume: 0,
				time: 2,
				transition: "easeInOutQuad"
			});
			Tweener.addTween(soundBChannel, {
				_sound_volume: 0,
				time: 2,
				transition: "easeInOutQuad"

			});
		}
		public function playSoundtrack(url) {
			var loop;
			switch (url) {
				case "i.mp3":
					loop = new loop1();
					break;
				case "ii.mp3":
					loop = new loop2();
					break;
				case "iii.mp3":
					loop = new loop3();
					break;
			}
			if (trackAPlaying == false && trackBPlaying == false) {
				soundAChannel = loop.play(0,999);
				Tweener.addTween(soundAChannel, {
					_sound_volume: 0,
					time: 0
				});
				trackAPlaying = true;
			} else if (trackAPlaying == true && trackBPlaying == false) {
				soundAChannel.stop();
				trackAPlaying = false;
				soundBChannel = loop.play(0,999);
				Tweener.addTween(soundBChannel, {
					_sound_volume: 0,
					time: 0
				});
				trackBPlaying = true;
			} else if (trackAPlaying == false && trackBPlaying == true) {
				soundBChannel.stop();
				trackBPlaying = false;
				soundAChannel = loop.play(0,999);
				Tweener.addTween(soundAChannel, {
					_sound_volume: 0,
					time: 0
				});
				trackAPlaying = true;
			}
			/*
			var request:URLRequest = new URLRequest(url);
			if (trackAPlaying == false && trackBPlaying == false) {
				soundA = new Sound();
				soundA.load(request);
				soundA.addEventListener(Event.COMPLETE, completeHandler, false, 0, true);
			}
			if (trackAPlaying == true && trackBPlaying == false) {
				soundB = new Sound();
				soundB.load(request);
				soundB.addEventListener(Event.COMPLETE, completeHandler, false, 0, true);
			}
			if (trackAPlaying == false && trackBPlaying == true) {
				soundA = new Sound();
				soundA.load(request);
				soundA.addEventListener(Event.COMPLETE, completeHandler, false, 0, true);
			}
			*/
		}
		private function completeHandler(event:Event):void {
			if (trackAPlaying == false && trackBPlaying == false) {
				soundAChannel = event.target.play(0,999);
				Tweener.addTween(soundAChannel, {
					_sound_volume: 0,
					time: 0
				});
				trackAPlaying = true;
				//soundAChannel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler, false, 0, true);
				return;
			}
			if (trackAPlaying == true && trackBPlaying == false) {
				soundAChannel.stop();
				trackAPlaying = false;
				soundBChannel = event.target.play(0,999);
				Tweener.addTween(soundBChannel, {
					_sound_volume: 0,
					time: 0
				});
				trackBPlaying = true;
				//soundBChannel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler, false, 0, true);
				return;
			}
			if (trackAPlaying == false && trackBPlaying == true) {
				soundBChannel.stop();
				trackBPlaying = false;
				soundAChannel = event.target.play(0,999);
				Tweener.addTween(soundAChannel, {
					_sound_volume: 0,
					time: 0
				});
				trackAPlaying = true;
				//soundAChannel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler, false, 0, true);
				return;
			}
		}
		private function soundCompleteHandler(event:Event):void {
			event.target.removeEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
			if (event.target == soundAChannel) {
				soundAChannel = soundA.play(0,999);
				soundAChannel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler, false, 0, true);
			}
			if (event.target == soundBChannel) {
				soundBChannel = soundB.play(0,999);
				soundBChannel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler, false, 0, true);
			}
		}
	}
}
