package org.justincrounds.actionscript {
	import flash.events.*;
	import nl.demonsters.debugger.MonsterDebugger;
	// Controller Singleton Object
	public class Controller extends EventDispatcher {
		private var debugger:MonsterDebugger;
		public var view:View;
		public var model:Model;
		public function Controller() {
			if (CONFIG::development) {
				debugger = new MonsterDebugger(this);
			}
			view = new View();
			model = new Model();
			view.controller = this;
			model.controller = this;
		}
		public function broadcast(string:String, object:Object = null):void {
			trace("Controller broadcast " + string + " : " + object);
			if (CONFIG::development) {
				this.debug("Controller broadcast " + string + " : " + object);
			}
			dispatchEvent(new BroadcastEvent(string, object));
		}
		public function debug(s:String):void {
			MonsterDebugger.trace(this, s);
		}
	}
}
