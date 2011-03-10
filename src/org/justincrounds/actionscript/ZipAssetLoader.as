package org.justincrounds.actionscript {
	import deng.fzip.*;
	import flash.display.*;
	public class ZipAssetLoader extends Actor {
		private var _asset:String;
		public function ZipAssetLoader() {
		}
		public function set asset(s:String):void {
			_asset = s;
			var zip:FZip = controller.model.dictionary['assets'] as FZip;
			var file:FZipFile = zip.getFileByName(_asset);
			var loader:Loader = new Loader();
			loader.loadBytes(file.content);
			addChild(loader);
		}
	}
}
