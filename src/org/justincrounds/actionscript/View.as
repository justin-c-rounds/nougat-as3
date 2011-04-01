package org.justincrounds.actionscript {
	import com.iainlobb.gamepad.*;
	import caurina.transitions.*;
	import coreyoneil.collision.*;
	import flash.display.*;
	import flash.events.*;
	import flash.utils.Dictionary;
	// View Singleton Object
	public class View extends MovieClip {
		private var _controller:Controller;
		public var factory:Factory = new Factory();
		private var keyBuffer:Number;
		private var _gamepad:Gamepad;
		public var stageWidth:Number;
		public var stageHeight:Number;
		public var collisionGroup:CollisionGroup = new CollisionGroup();
		public var scenario:MovieClip = new MovieClip();
		public function View() {
			addChild(scenario);
			addEventListener(Event.ADDED_TO_STAGE, addedToStage, false, 0, true);
		}
		public function set controller(controller:Controller):void {
			_controller = controller;
			factory.controller = _controller;
			_controller.addEventListener("LOAD SCENARIO", eventHandler, false, 0, true);
		}
		public function get gamepad():Gamepad {
			return _gamepad;
		}
		private function eventHandler(event:BroadcastEvent):void {
			switch (event.type) {
				case "LOAD SCENARIO":
					loadScenario(event.object.toString());
					break;
			}
		}
		private function loadScenario(scenarioID:String):void {
			collisionGroup = new CollisionGroup();
			removeChild(scenario);
			scenario = new MovieClip();
			addChild(scenario);
			var scenarioXML:XMLList = _controller.model.blueprint.scenario.(@id == scenarioID);
			for each (var actor:XML in scenarioXML.child("actor")) {
				var thisActor:Actor = scenario.addChild(factory.build(actor.attributes())) as Actor;
				// build actor's dictionary (if present)
				var dictionary:XMLList = actor.child("dictionary");
				if (dictionary.length() != 0) {
					thisActor.dictionary = new Dictionary(true);
					for each (var entry:XMLList in dictionary.child("entry")) {
						thisActor.dictionary[entry.attribute("key").toString()] = entry.attribute("value").toString();
					}
				}
				// some layer actors may contain "child" elements, so check for children and add accordingly
				for each (var child:XML in actor.child("child")) {
					var thisChild:Actor = thisActor.addChild(factory.build(child.attributes())) as Actor;
					if (child.children().length() > 0) {
						thisChild.xml = child.children();
					}
				}
				// pass actor.children to actor -- THIS WILL BECOME THE STANDARD METHOD FOR PASSING DATA TO ACTORS
				if (actor.children().length() > 0) {
					thisActor.xml = actor.children();
				}
				thisActor.init();
			}
		}
		private function addedToStage(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			// first create the mask for the display area
			stageWidth = parseInt(_controller.model.blueprint.meta.stage.attribute("width").toString());
			stageHeight = parseInt(_controller.model.blueprint.meta.stage.attribute("height").toString());
			var maskSprite:Sprite = new Sprite();
			maskSprite.graphics.beginFill(0x000000);
			maskSprite.graphics.drawRect(0, 0, stageWidth, stageHeight);
			this.addChild(maskSprite);
			this.mask = maskSprite;
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown, false, 0, true);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUp, false, 0, true);
			_gamepad = new Gamepad(stage, true);
		}
		private function keyDown(event:KeyboardEvent):void {
			if (event.keyCode != keyBuffer) {
				_controller.broadcast("KEY DOWN", event.keyCode);
				keyBuffer = event.keyCode;
			}
		}
		private function keyUp(event:KeyboardEvent):void {
			_controller.broadcast("KEY UP", event.keyCode);
			if (event.keyCode == keyBuffer) {
				keyBuffer = 0;
			}
		}
	}
}
