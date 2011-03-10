package org.justincrounds.actionscript {
	import flash.events.*;
	import flash.display.MovieClip;
	import flash.utils.Dictionary;
	public class Actor extends MovieClip {
		protected var _controller:Controller;
		protected var _xml:XMLList;
		protected var _dictionary:Dictionary;
		public function Actor() {
			this.addEventListener(Event.ADDED_TO_STAGE, addedToStage, false, 0, true);
		}
		public function init():void {
		}
		public function set controller(c:Controller):void {
			_controller = c;
		}
		public function get controller():Controller {
			return _controller;
		}
		public function set xml(d:XMLList):void {
			_xml = d;
		}
		public function get xml():XMLList {
			return _xml;
		}
		public function set dictionary(d:Dictionary):void {
			_dictionary = d;
		}
		public function get dictionary():Dictionary {
			return _dictionary;
		}
		protected function addedToStage(e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			this.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage, false, 0, true);
		}
		protected function removedFromStage(e:Event):void {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
			_controller = null;
			this.stop();
		}
	}
}
