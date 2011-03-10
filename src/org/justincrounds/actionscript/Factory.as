package org.justincrounds.actionscript {
	import flash.utils.*;
	// Factory Singleton
	public class Factory {
		public var controller:Controller;
		public function Factory() {
		}
		public function build(objectAttributes:XMLList):Actor {
			var ClassReference:Class = getDefinitionByName(objectAttributes[0].toString()) as Class;
			var instance:Actor = new ClassReference();
			instance.controller = controller;
			for (var i:Number = 1; i < objectAttributes.length(); i++) {
				var parseString:String = objectAttributes[i].toString();
				if (isNaN(parseFloat(parseString))) {
					if (parseString == "true") {
						instance[objectAttributes[i].name().toString()] = true;
					} else if (parseString == "false") {
						instance[objectAttributes[i].name().toString()] = false;
					} else {
						instance[objectAttributes[i].name().toString()] = parseString;
					}
				} else {
					instance[objectAttributes[i].name().toString()] = parseFloat(parseString);
				}
			}
			instance.init();
			return instance;
		}
	}
}
