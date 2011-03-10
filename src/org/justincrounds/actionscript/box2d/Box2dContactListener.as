package org.justincrounds.actionscript.box2d {
	import org.justincrounds.actionscript.box2d.*;
	import Box2D.Dynamics.*;
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Dynamics.Joints.*;
	import Box2D.Dynamics.Contacts.*;
	import Box2D.Common.*;
	import Box2D.Common.Math.*;
	public class Box2dContactListener extends b2ContactListener {
		public var contacts:Array = new Array();
		public function Box2dContactListener() {
		}
		public override function Add(point:b2ContactPoint):void {
			var shape1:b2Shape = point.shape1;
			var shape2:b2Shape = point.shape2;
			var separation:Number = point.separation;
			var position:b2Vec2 = point.position.Copy();
			contacts.push(new Box2dContactPoint(shape1,shape2,separation,position));
		}
	}
}
