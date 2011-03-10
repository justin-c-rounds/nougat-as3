package org.justincrounds.actionscript.box2d {
	import org.justincrounds.actionscript.box2d.*;
	import org.justincrounds.actionscript.*;
	import Box2D.Dynamics.*;
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Dynamics.Joints.*;
	import Box2D.Dynamics.Contacts.*;
	import Box2D.Common.*;
	import Box2D.Common.Math.*;
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	// Abstraction layer for Box2d simulation
	public class Box2dLayer extends MovieClip {
		public var actors:Dictionary = new Dictionary(true);
		public var bodies:Dictionary = new Dictionary(true);
		private var _width:Number;
		private var _height:Number;
		private var _gravity:Number;
		private var _gravityDirection:Number;
		public var world:b2World;
		private var iterations:int = 10;
		private var timeStep:Number = 1.0/60.0;
		private var paused:Boolean = false;
		private var _controller:Controller;
		public function Box2dLayer() {
			// don't build anything yet...
			addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage, false, 0, true);
		}
		public function set controller(controller:Controller) {
			_controller = controller;
			_controller.addEventListener("PAUSE", pauseHandler, false, 0, true);
		}
		public override function set width(value:Number):void {
			_width = value;
			// wait until width, height, and gravity are known before building
			if (_width && _height && (_gravity || _gravity == 0) && (_gravityDirection || _gravityDirection == 0)) {
				buildWorld();
			}
		}
		public override function set height(value:Number):void {
			_height = value;
			// wait until width, height, and gravity are known before building
			if (_width && _height && (_gravity || _gravity == 0) && (_gravityDirection || _gravityDirection == 0)) {
				buildWorld();
			}
		}
		public function set gravity(value:Number):void {
			_gravity = value;
			// wait until width, height, and gravity are known before building
			if (_width && _height && (_gravity || _gravity == 0) && (_gravityDirection || _gravityDirection == 0)) {
				buildWorld();
			}
		}
		public function set gravityDirection(value:Number):void {
			_gravityDirection = value;
			// wait until width, height, and gravity are known before building
			if (_width && _height && (_gravity || _gravity == 0) && (_gravityDirection || _gravityDirection == 0)) {
				buildWorld();
			}
		}
		private function buildWorld() {
			// Add event for main loop
			addEventListener(Event.ENTER_FRAME, enterFrame, false, 0, true);
			// Create world AABB
			var worldAABB:b2AABB = new b2AABB();
			worldAABB.lowerBound.Set(0.0, _height * -0.1);
			worldAABB.upperBound.Set(_width * 0.1, 0.0);
			// Define the gravity vector
			var gravity:b2Vec2 = new b2Vec2 (Math.sin(_gravityDirection * (Math.PI / 180)), Math.cos(_gravityDirection * (Math.PI / 180)));
			gravity.Multiply(_gravity);
			// Allow bodies to sleep
			var doSleep:Boolean = true;
			// Construct a world object
			world = new b2World(worldAABB, gravity, doSleep);
		}
		public override function addChild(child:DisplayObject):DisplayObject {
			var _child = child;
			var bodyDef = new b2BodyDef();
			bodyDef.position.Set(_child.x * 0.1, _child.y * -0.1);
			if (_child.fixedRotation) {
				bodyDef.fixedRotation = true;
			}
			var body:b2Body = world.CreateBody(bodyDef);
			var shapeDef:b2PolygonDef = new b2PolygonDef();
			shapeDef.SetAsBox(_child.width * 0.05, _child.height * 0.05);
			if (_child.isDynamic) {
				shapeDef.density = _child.density;
				shapeDef.friction = _child.friction;
				shapeDef.restitution = _child.restitution;
			}
			body.CreateShape(shapeDef);
			if (_child.isDynamic) {
				body.SetMassFromShapes();
			}
			var mc = super.addChild(_child);
			mc.name = _child.name;
			var actor = new Box2dActor(body, mc);
			actor.isDynamic = _child.isDynamic;
			actors[_child.name] = actor;
			bodies[body] = actor;
			dispatchEvent(new Event(_child.name + " added"));
			return child;
		}
		public function createJoint(jointType:String, obj1:Box2dActor, obj2:Box2dActor, args:Object = null) {
			var jointDef;
			var joint;
			switch (jointType) {
				case "distance":
					// currently broken... not sure why
					jointDef = new b2DistanceJointDef();
					jointDef.Initialize(obj1.body, obj2.body, obj1.body.GetWorldCenter(), obj2.body.GetWorldCenter());
					jointDef.collideConnected = true;
					break;
				case "revolute":
					jointDef = new b2RevoluteJointDef();
					jointDef.Initialize(obj1.body, obj2.body, obj1.body.GetWorldCenter());
					jointDef.lowerAngle     = 0 * b2Settings.b2_pi; // -90 degrees
					jointDef.upperAngle     = 0 * b2Settings.b2_pi; // 45 degrees
					jointDef.enableLimit    = true;
					jointDef.maxMotorTorque = 10.0;
					jointDef.motorSpeed     = 0.0;
					jointDef.enableMotor    = false;
					break;
				case "prismatic":
					var worldAxis:b2Vec2 = new b2Vec2(1.0, 0.0);
					jointDef = new b2PrismaticJointDef();
					jointDef.Initialize(obj1.body, obj2.body, obj1.body.GetWorldCenter(), worldAxis);
					jointDef.lowerTranslation= 0;
					jointDef.upperTranslation= 0;
					jointDef.enableLimit = true;
					jointDef.maxMotorForce = 1.0;
					jointDef.motorSpeed = 0.0;
					jointDef.enableMotor = true;
					break;
				case "pulley":
					break;
				case "gear":
					break;
				case "mouse":
					break;
			}
			joint = world.CreateJoint(jointDef);
			return joint;
		}
		private function pauseHandler(event:BroadcastEvent) {
			paused = !paused;
		}
		private function enterFrame(event:Event) {
			if (!paused) {
				world.Step(timeStep, iterations);
				for each (var actor in actors) {
					if (actor.body.IsFrozen()) {
						// remove bodies that are frozen
						removeChild(actor.graphic);
						var key = actor.graphic.name;
						actors[key] = null;
						delete actors[key];
						bodies[actor.body] = null;
						delete bodies[actor.body];
						world.DestroyBody(actor.body);
					} else {
						var bodyPosition:b2Vec2 = actor.body.GetPosition();
						var bodyRotation:Number = actor.body.GetAngle();
						actor.graphic.x = bodyPosition.x * 10;
						actor.graphic.y = bodyPosition.y * -10;
						actor.graphic.rotation = -(bodyRotation  * (180/Math.PI) % 360); //Don't forget to convert to degrees!
					}
				}
			}
		}
		private function removedFromStage(event:Event) {
			stop();
			removeEventListener(Event.ENTER_FRAME, enterFrame);
			removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
		}
	}
}
