package org.justincrounds.actionscript {
	import com.adobe.serialization.json.*
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;
	import flash.system.*;
	public class JSONLoader extends URLLoader {
		private var progress:Number;
		private var _url:String;
		//private var loader:Loader = new Loader();
		//private var applicationDomain:ApplicationDomain = new ApplicationDomain(null);
		// comment out the line below when testing locally
		//private var loaderContext:LoaderContext = new LoaderContext(false, applicationDomain, SecurityDomain.currentDomain);
		//private var loaderContext:LoaderContext = new LoaderContext(false, applicationDomain);
		public function JSONLoader() {
			//loader.contentLoaderInfo.addEventListener(Event.OPEN, loadStart, false, 0, true);
			//this.addEventListener(IOErrorEvent.IO_ERROR, loadError, false, 0, true);
			//loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, loadProgress, false, 0, true);
			this.addEventListener(Event.COMPLETE, loadComplete, false, 0, true);
		}
		public function set url(url:String):void {
			this.data = null;
			_url = url;
			var request:URLRequest = new URLRequest(url);
			// comment out the line below when testing locally
			//loader.load(request, loaderContext);
			// uncomment out the line below when testing locally
			this.load(request);
		}
		/*
		private function loadStart(event:Event) {
			loader.contentLoaderInfo.removeEventListener(Event.OPEN, loadStart);
			Security.allowDomain(loader.contentLoaderInfo.url)
			//controller.broadcast("JSON LOADING", _url);
		}
		private function loadProgress(event:ProgressEvent) {
			progress = Math.floor((event.target.bytesLoaded / event.target.bytesTotal) * 100);
			//controller.broadcast("JSON LOADING PROGRESS", progress);
		}
		*/
		protected function loadComplete(e:Event):void {
			//loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, loadProgress);
			dispatchEvent(new BroadcastEvent("JSON LOADED", JSON.decode(this.data)));
		}
		public function post(u:String, d:String):void {
			var request:URLRequest = new URLRequest(u);
			var variables:URLVariables = new URLVariables(encodeURI(d));
			request.data = variables;
			request.method = URLRequestMethod.POST;
			this.load(request);
		}
	}
}
