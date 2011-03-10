package org.justincrounds.actionscript.box2d {
	import Box2D.Dynamics.*;
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Dynamics.Joints.*;
	import Box2D.Dynamics.Contacts.*;
	import Box2D.Common.*;
	import Box2D.Common.Math.*;
	import flash.display.*;
	public class Box2dActor {
		public var body:b2Body;
		public var graphic:DisplayObject;
		public var name:String;
		public var mass:Number;
		private var _isDynamic:Boolean;
		public function Box2dActor(b:b2Body, g:DisplayObject) {
			body = b;
			graphic = g;
			mass = body.GetMass();
		}
		public function setPosition(x:Number, y:Number) {
			body.SetXForm(new b2Vec2(x * 0.1, y * -0.1), body.GetAngle());
		}
		public function set rotation(rotation:Number) {
			body.SetXForm(body.GetPosition(), rotation * (Math.PI / 180));
		}
		public function get rotation() {
			return body.GetAngle() * (180 / Math.PI);
		}
		public function get x() {
			return graphic.x;
		}
		public function get y() {
			return graphic.y;
		}
		public function set isDynamic(isDynamic:Boolean) {
			var massData = new b2MassData();
			if (_isDynamic && !isDynamic) {
				mass = body.GetMass();
				massData.mass = 0;
				massData.center = body.GetLocalCenter();
				massData.I = body.GetInertia();
				body.SetMass(massData);
				_isDynamic = false;
			} else if (!_isDynamic && isDynamic) {
				massData.mass = mass;
				massData.center = body.GetLocalCenter();
				massData.I = body.GetInertia();
				body.SetMass(massData);
				_isDynamic = true;
			}
		}
		public function get isDynamic() {
			return _isDynamic;
		}
		public function ApplyImpulse(direction:Number, force:Number) {
			var impulse = new b2Vec2(Math.sin(direction * (Math.PI / 180)), Math.cos(direction * (Math.PI / 180)));
			impulse.Multiply(force);
			body.ApplyImpulse(impulse, body.GetPosition());
		}
		public function ApplyForce(direction:Number, force:Number) {
			var impulse = new b2Vec2(Math.sin(direction * (Math.PI / 180)), Math.cos(direction * (Math.PI / 180)));
			impulse.Multiply(force);
			body.ApplyForce(impulse, body.GetPosition());
		}
		public function SetLinearVelocity(direction:Number, force:Number) {
			var impulse = new b2Vec2(Math.sin(direction * (Math.PI / 180)), Math.cos(direction * (Math.PI / 180)));
			impulse.Multiply(force);
			body.SetLinearVelocity(impulse);
		}
	}
}
