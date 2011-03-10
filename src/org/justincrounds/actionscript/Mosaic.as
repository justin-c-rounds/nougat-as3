package org.justincrounds.actionscript {
	import de.polygonal.ds.*;
	import flash.utils.*;
	import flash.display.*;
	public class Mosaic extends Actor {
		private var _width:Number = 0;
		private var _height:Number = 0;
		private var _x:Number = 0;
		private var _y:Number = 0;
		private var frame:MovieClip = new MovieClip();
		private var frameMask:Sprite = new Sprite();
		private var array3:Array3;
		public var currentRow:Number = 0;
		public var currentCell:Number = 0;
		public var tileWidth:Number = 0;
		public var tileHeight:Number = 0;
		private var panX:Number = 0;
		private var panY:Number = 0;
		public function Mosaic() {
		}
		public override function set x(x:Number):void {
			_controller == null ? super.x = x : _controller.broadcast("MOSAIC PAN", { name: name, x: x - _x, y: 0 });
			_x = x;
		}
		public override function set y(y:Number):void {
			_controller == null ? super.y = y : _controller.broadcast("MOSAIC PAN", { name: name, x: 0, y: y - _y });
			_y = y;
		}
		public override function get x():Number {
			return _x;
		}
		public override function get y():Number {
			return _y;
		}
		public override function set width(width:Number):void {
			_width = width;
			_height != 0 ? buildFrame() : null;
		}
		public override function set height(height:Number):void {
			_height = height;
			_width != 0 ? buildFrame() : null;
		}
		private function buildFrame():void {
			frameMask.graphics.beginFill(0x000000, 0.0);
			frameMask.graphics.drawRect(0, 0, _width, _height);
			frameMask.graphics.endFill();
			addChild(frameMask);
			frame.mask = frameMask;
			addChild(frame);
		}
		override public function set controller(controller:Controller):void {
			super.controller = controller;
			controller.addEventListener("MOSAIC PAN", mosaicPan, false, 0, true);
		}
		private function mosaicPan(event:BroadcastEvent):void {
			if (name == event.object.name) {
				frame.x += event.object.x;
				panX += event.object.x;
				if (panX >= tileWidth) {
					frame.x -= tileWidth;
					currentCell--;
					panX = 0;
				}
				if (panX <= -tileWidth) {
					frame.x += tileWidth;
					currentCell++;
					panX = 0;
				}
				frame.y += event.object.y;
				panY += event.object.y;
				if (panY >= tileHeight) {
					frame.y -= tileHeight;
					currentRow--;
					panY = 0;
				}
				if (panY <= -tileHeight) {
					frame.y += tileHeight;
					currentRow++;
					panY = 0;
				}
			}
		}
		override public function set xml(d:XMLList):void {
			super.xml = d
			// for convenience, convert the tilegrid xml into an array3
			for each (var layer:XML in _xml.child("layer")) {
				for each (var tile:XML in layer.child("tile")) {
					buildTile(tile.attribute('tileX'), tile.attribute('tileY'), tile);
				}
			}
		}
		/*
		private function buildTiles():void {
			// destroy current tileset
			for (var childIndex:Number = 0; childIndex < frame.numChildren; childIndex++) {
				var thisChild:Actor = frame.getChildAt(childIndex) as Actor;
				thisChild.stop();
				frame.removeChild(thisChild);
				thisChild = null;
			}
			// if tile dimensions are undefined in the xml or set larger than the frame then set to the frame dimensions, otherwise conform to an even division of frame
			tileWidth == 0 || tileWidth > _width ? tileWidth = _width : tileWidth = _width / Math.round(_width / tileWidth);
			tileHeight == 0 || tileHeight > _height ? tileHeight = _height : tileHeight = _height / Math.round(_height / tileHeight);
			// determine how many tiles to build
			var xTiles:Number = (_width / tileWidth) + 2;
			var yTiles:Number = (_height / tileHeight) + 2;
			// determine offsets for tile coordinates
			for (var i:Number = -1; i < xTiles - 1; i++) {
				for (var ii:Number = -1; ii < yTiles - 1; ii++) {
					buildTile(currentRow, currentCell, i, ii);
				}
			}
		}
		*/
		private function buildTile(tileX:Number, tileY:Number, tileData:XML):void {
			var thisTile:Actor = frame.addChild(controller.view.factory.build(tileData.attributes())) as Actor;
			thisTile.x = tileWidth * tileX;
			thisTile.y = tileHeight * tileY;
		}
	}
}
