package org.justincrounds.actionscript.box2d {
	import org.justincrounds.actionscript.box2d.*;
	import Box2D.Dynamics.*;
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Dynamics.Joints.*;
	import Box2D.Dynamics.Contacts.*;
	import Box2D.Common.*;
	import Box2D.Common.Math.*;
	public class Box2dContactPoint {
		public var shape1:b2Shape;
		public var shape2:b2Shape;
		public var separation:Number;
		public var position:b2Vec2;
		public function Box2dContactPoint (s1:b2Shape,s2:b2Shape, f:Number, p:b2Vec2) {
			shape1 = s1;
			shape2 = s2;
			separation = f;
			position = p;
		}
		public function get x():Number {
			return position.x * 10;
		}
		public function get y():Number {
			return position.y * -10;
		}
	}
}
