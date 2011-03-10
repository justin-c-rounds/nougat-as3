package org.justincrounds.actionscript {
	import flash.events.Event;
	public class BroadcastEvent extends Event {
		public var object:Object;
		public function BroadcastEvent(type:String, obj:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			object = obj;
		}
		public override function clone():Event {
			return new BroadcastEvent(type, object, bubbles, cancelable);
		}
	}
}
