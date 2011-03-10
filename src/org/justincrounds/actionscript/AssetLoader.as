package org.justincrounds.actionscript {
	import flash.net.*;
	import flash.display.*;
	import flash.events.*;
	import flash.system.*;
	import flash.geom.Rectangle;
	public class AssetLoader extends Actor {
		private var shape:Shape = new Shape();
		private var progress:Number;
		private var _url:String;
		private var loader:Loader = new Loader();
		private var applicationDomain:ApplicationDomain = new ApplicationDomain(null);
		/* Comment out the line below when testing locally in the Flash IDE. */
		private var loaderContext:LoaderContext = new LoaderContext(false, applicationDomain, SecurityDomain.currentDomain);
		/* Comment out the line below when building for release. */
		//private var loaderContext:LoaderContext = new LoaderContext(false, applicationDomain);
		public function AssetLoader() {
			shape.graphics.beginFill(0x000000, 0);
			shape.graphics.drawRect(0, 0, 1, 1);
			shape.graphics.endFill();
			addChild(shape);
			loader.contentLoaderInfo.addEventListener(Event.OPEN, loadStart, false, 0, true);
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, loadProgress, false, 0, true);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete, false, 0, true);
		}
		public override function set width(w:Number):void {
			shape.width = w;
			super.width = w;
		}
		public override function set height(h:Number):void {
			shape.height = h;
			super.height = h;
		}
		public function set url(url:String):void {
			_url = url;
			var request:URLRequest = new URLRequest(url);
			loader.load(request, loaderContext);
		}
		public function get sharedEvents():EventDispatcher {
			return loader.contentLoaderInfo.sharedEvents;
		}
		private function loadStart(event:Event):void {
			loader.contentLoaderInfo.removeEventListener(Event.OPEN, loadStart);
			controller.broadcast("ASSET LOADING", _url);
		}
		private function loadProgress(event:ProgressEvent):void {
			progress = Math.floor((event.target.bytesLoaded / event.target.bytesTotal) * 100);
			controller.broadcast("ASSET LOADING PROGRESS", progress);
		}
		private function loadComplete(event:Event):void {
			loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, loadProgress);
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadComplete);
			var asset:DisplayObject = addChild(loader.content);
			controller.broadcast("ASSET LOADED", asset);
			dispatchEvent(new BroadcastEvent("ASSET LOADED", asset));
			loader.content.width = shape.width > 1 ? shape.width : loader.content.width;
			loader.content.height = shape.height > 1 ? shape.height : loader.content.height;
		}
	}
}
