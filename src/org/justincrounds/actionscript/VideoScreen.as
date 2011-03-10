package org.justincrounds.actionscript {
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.media.Video;
	public class VideoScreen extends MovieClip {
		private var _controller:Controller;
		private var _width:Number;
		private var _height:Number;
		private var netConnection:NetConnection = new NetConnection();
		private var netStream:NetStream;
		public var videoURL:String;
		private var video:Video;
		private var isPaused:Boolean = false;
		public function VideoScreen() {
			stop();
			addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage, false, 0, true);
		}
		public override function set width(width:Number):void {
			_width = width;
		}
		public override function set height(height:Number):void {
			_height = height;
		}
		public function set controller(controller:Controller) {
			_controller = controller;
			_controller.addEventListener("PAUSE", pauseHandler, false, 0, true);
			var child:Shape = new Shape();
			child.graphics.beginFill(0x000000);
			child.graphics.drawRect(0, 0, _width, _height);
			child.graphics.endFill();
			child.alpha = 0.5;
			addChild(child);
			netConnection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler, false, 0, true);
			netConnection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler, false, 0, true);
			netConnection.connect(null); 
		}
		private function netStatusHandler(event:NetStatusEvent) {
			trace(event.info.code);
			switch (event.info.code) {
				case "NetConnection.Connect.Success":
					netStream = new NetStream(netConnection);
					netStream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler, false, 0, true);
					netStream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler, false, 0, true);
					video = new Video(_width, _height);
					video.smoothing = false;
					video.attachNetStream(netStream);
					netStream.play(videoURL);
					addChild(video);
					trace(video.x);
					break;
				case "NetStream.Play.StreamNotFound":
					trace("Unable to locate video: " + videoURL);
					break;
				case "NetStream.Play.Start":
					_controller.broadcast("VIDEO START", videoURL);
					break;
				case "NetStream.Play.Stop":
					_controller.broadcast("VIDEO STOP", videoURL);
					break;
			}
		}
		private function securityErrorHandler(event:SecurityErrorEvent):void {
		    trace("securityErrorHandler: " + event);
		}
		
		private function asyncErrorHandler(event:AsyncErrorEvent):void {
		    // ignore AsyncErrorEvent events.
		}
		private function pauseHandler(event:BroadcastEvent) {
			if (!isPaused) {
				netStream.pause();
			} else {
				netStream.resume();
			}
			isPaused = !isPaused;
		}
		private function removedFromStage(event:Event) {
			netStream.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			netStream.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			netStream.close();
			netStream = null;
			netConnection.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			netConnection.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			netConnection = null;
			removeChild(video);
			video = null;
			_controller.removeEventListener("PAUSE", pauseHandler);
		}
	}
}
