package org.justincrounds.actionscript {
	// Model Singleton Object
	import flash.utils.Dictionary;
	public class Model {
		public var controller:Controller;
		public var dictionary:Dictionary = new Dictionary(true);
		private var _blueprint:XML;
		public function Model() {
		}
		public function set blueprint(xml:XML):void {
			_blueprint = xml;
		}
		public function get blueprint():XML {
			return _blueprint;
		}
	}
}
