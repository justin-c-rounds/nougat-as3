/*

Licensed under the MIT License

Copyright (c) 2008 Corey O'Neil
www.coreyoneil.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

package coreyoneil.collision
{
	import flash.display.DisplayObject;
	import flash.display.BitmapData;
	import flash.errors.EOFError;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.geom.Matrix;
	import flash.geom.ColorTransform;
	import flash.utils.ByteArray;
	import flash.text.TextFormat;
	import flash.utils.getQualifiedClassName;
	
	
	
	public class CDK
	{
		private var _root;
		
		protected var objectArray:Array;
		protected var objectCheckArray:Array;
		protected var objectCollisionArray:Array;
		private var colorExclusionArray:Array;
		
		private var bmd1:BitmapData;
		private var bmd2:BitmapData;
		private var bmdResample:BitmapData;
		
		private var pixels1:ByteArray;
		private var pixels2:ByteArray;
		
		private var rect1:Rectangle;
		private var rect2:Rectangle;
		
		private var transMatrix1:Matrix;
		private var transMatrix2:Matrix;
		
		private var colorTransform1:ColorTransform;
		private var colorTransform2:ColorTransform;
		
		private var item1Registration:Point;
		private var item2Registration:Point;
		
		private var _alphaThreshold:Number;
		
		private var _returnAngle:Boolean;
		
		private var _returnAngleType:String;
		
		private var _numChildren:uint;

		public function CDK():void 
		{	
			if(getQualifiedClassName(this) == "coreyoneil.collision::CDK")
			{
            	throw new Error('CDK is an abstract class and is not meant for instantiation - use CollisionGroup or CollisionList');
			}
			
			init();
		}
		
		private function init():void
		{			
			objectCheckArray = new Array();
			objectCollisionArray = new Array();
			objectArray = new Array();
			colorExclusionArray = new Array();
			
			_alphaThreshold = 0;
			_returnAngle = false;
			_returnAngleType = "RADIANS";
		}
		
		public function addItem(obj):void 
		{
			if(obj is DisplayObject)
			{
				_root = obj.root;
				
				if(_root == null)
				{
					throw new Error("Cannot add item: " + obj + " - Items added for collision detection must be on the display list.");
				}
				
				objectArray.push(obj);
			}
			else
			{
				throw new Error("Cannot add item: " + obj + " - item must be a Display Object.");
			}
		}
		
		public function removeItem(obj):void 
		{
			var found:Boolean = false, numObjs:int = objectArray.length;
			for(var i:uint = 0; i < numObjs; i++)
			{
				if(objectArray[i] == obj)
				{
					objectArray.splice(i, 1);
					found = true;
					break;
				}
			}
			
			if(!found)
			{
				throw new Error(obj + " could not be removed - object not found in item list.");
			}
		}
		
		public function excludeColor(theColor:uint, alphaRange:uint = 255, redRange:uint = 20, greenRange:uint = 20, blueRange:uint = 20):void
		{
			var colorExclusion:Object = {color:theColor, alpha:alphaRange, red:redRange, green:greenRange, blue:blueRange};
			colorExclusionArray.push(colorExclusion);
		}
		
		public function removeExcludeColor(theColor:uint):void
		{
			var found:Boolean = false, numColors:int = colorExclusionArray.length;
			for(var i:uint = 0; i < numColors; i++)
			{
				if(colorExclusionArray[i].color == theColor)
				{
					colorExclusionArray.splice(i, 1);
					found = true;
					break;
				}
			}
			
			if(!found)
			{
				throw new Error("Color could not be removed - color not found in exclusion list [" + theColor + "]");
			}
		}
		
		protected function clearArrays():void
		{
			while(objectCheckArray.length)
			{
				objectCheckArray.pop();
			}
			
			while(objectCollisionArray.length)
			{
				objectCollisionArray.pop();
			}
		}
		
		protected function findCollisions(item1, item2):void
		{
			var item1_isText:Boolean = false, item2_isText:Boolean = false;

			try
			{
				var tf:TextFormat = item1.getTextFormat();
				item1_isText = (item1.antiAliasType == "advanced") ? true : false;
				item1.antiAliasType = (item1.antiAliasType == "advanced") ? "normal" : item1.antiAliasType;
			}
			catch(e:Error)
			{}
			
			try
			{
				tf = item2.getTextFormat();
				item2_isText = (item1.antiAliasType == "advanced") ? true : false;
				item2.antiAliasType = (item2.antiAliasType == "advanced") ? "normal" : item2.antiAliasType;
			}
			catch(e:Error)
			{}
			
			colorTransform1 = item1.transform.colorTransform;
			colorTransform2 = item2.transform.colorTransform;
			
			item1Registration = new Point(item1.x, item1.y);
			item2Registration = new Point(item2.x, item2.y);

			item1Registration = item1.parent.localToGlobal(item1Registration);
			item2Registration = item2.parent.localToGlobal(item2Registration);
			
			if((item2.width * item2.height) > (item1.width * item1.height))
			{
				bmd1 = new BitmapData(item1.width, item1.height, true, 0x00FFFFFF);  
				bmd2 = new BitmapData(item1.width, item1.height, true, 0x00FFFFFF);
				
				rect1 = item1.getBounds(_root.stage);
				
				transMatrix1 = item1.transform.matrix;
				transMatrix1.tx = (item1Registration.x - rect1.left);
				transMatrix1.ty = (item1Registration.y - rect1.top);
				
				transMatrix2 = item2.transform.matrix;
				transMatrix2.tx = (item2Registration.x - rect1.left);
				transMatrix2.ty = (item2Registration.y - rect1.top);
			}
			else
			{
				bmd1 = new BitmapData(item2.width, item2.height, true, 0x00FFFFFF);  
				bmd2 = new BitmapData(item2.width, item2.height, true, 0x00FFFFFF);
				
				rect2 = item2.getBounds(_root.stage);

				transMatrix1 = item1.transform.matrix;
				transMatrix1.tx = (item1Registration.x - rect2.left);
				transMatrix1.ty = (item1Registration.y - rect2.top);
				
				transMatrix2 = item2.transform.matrix;
				transMatrix2.tx = (item2Registration.x - rect2.left);
				transMatrix2.ty = (item2Registration.y - rect2.top);
			}
			
			bmd1.draw(item1, transMatrix1, colorTransform1, null, null, true);
			bmd2.draw(item2, transMatrix2, colorTransform2, null, null, true);
			
			pixels1 = bmd1.getPixels(new Rectangle(0, 0, bmd1.width, bmd1.height));
			pixels2 = bmd2.getPixels(new Rectangle(0, 0, bmd1.width, bmd1.height));	
			
			var k:uint = 0, value1:uint = 0, value2:uint = 0, collisionPoint:Number = -1, overlap:uint = 0;

			pixels1.position = 0;
			pixels2.position = 0;
			
			while(k < pixels1.length)
			{
				k = pixels1.position;
				
				try
				{
					value1 = pixels1.readUnsignedInt();
					value2 = pixels2.readUnsignedInt();
				}
				catch(e:EOFError)
				{
					break;
				}
				
				var alpha1:uint = value1 >> 24 & 0xFF, alpha2:uint = value2 >> 24 & 0xFF;
				
				if(alpha1 > _alphaThreshold && alpha2 > _alphaThreshold)
				{	
					var colorFlag:Boolean = false;
					if(colorExclusionArray.length)
					{
						var red1:uint = value1 >> 16 & 0xFF, red2:uint = value2 >> 16 & 0xFF, green1:uint = value1 >> 8 & 0xFF, green2:uint = value2 >> 8 & 0xFF, blue1:uint = value1 & 0xFF, blue2:uint = value2 & 0xFF;
						
						var a:uint, r:uint, g:uint, b:uint, item1Flags:uint, item2Flags:uint;
						
						for(var n:uint = 0; n < colorExclusionArray.length; n++)
						{
							a = colorExclusionArray[n].color >> 24 & 0xFF;
							r = colorExclusionArray[n].color >> 16 & 0xFF;
							g = colorExclusionArray[n].color >> 8 & 0xFF;
							b = colorExclusionArray[n].color & 0xFF;
							
							item1Flags = 0;
							item2Flags = 0;
							if((blue1 >= b - colorExclusionArray[n].blue) && (blue1 <= b + colorExclusionArray[n].blue))
							{
								item1Flags++;
							}
							if((blue2 >= b - colorExclusionArray[n].blue) && (blue2 <= b + colorExclusionArray[n].blue))
							{
								item2Flags++;
							}
							if((green1 >= g - colorExclusionArray[n].green) && (green1 <= g + colorExclusionArray[n].green))
							{
								item1Flags++;
							}
							if((green2 >= g - colorExclusionArray[n].green) && (green2 <= g + colorExclusionArray[n].green))
							{
								item2Flags++;
							}
							if((red1 >= r - colorExclusionArray[n].red) && (red1 <= r + colorExclusionArray[n].red))
							{
								item1Flags++;
							}
							if((red2 >= r - colorExclusionArray[n].red) && (red2 <= r + colorExclusionArray[n].red))
							{
								item2Flags++;
							}
							if((alpha1 >= a - colorExclusionArray[n].alpha) && (alpha1 <= a + colorExclusionArray[n].alpha))
							{
								item1Flags++;
							}
							if((alpha2 >= a - colorExclusionArray[n].alpha) && (alpha2 <= a + colorExclusionArray[n].alpha))
							{
								item2Flags++;
							}
							
							if((item1Flags == 4) || (item2Flags == 4))
							{
								colorFlag = true;
							}
						}
					}
					
					if((collisionPoint == -1) && (!colorFlag))
					{
						if(_returnAngle)
						{
							collisionPoint = k / 4;
							var angle:Number = findAngle(item1, item2, collisionPoint);
						}
						else
						{
							angle = -1;
							collisionPoint = 0;
						}

					}
					
					overlap = !colorFlag ? overlap + 1 : overlap;
				}
			}
			
			if(overlap)
			{
				if((item2.width * item2.height) < (item1.width * item1.height))
				{
					var recordedCollision:Object = {object1:item2, object2:item1, angle:angle, overlap:overlap}
					objectCollisionArray.push(recordedCollision);
				}
				else
				{
					recordedCollision = {object1:item1, object2:item2, angle:angle, overlap:overlap}
					objectCollisionArray.push(recordedCollision);
				}
			}
			
			if(item1_isText)
			{
				item1.antiAliasType = "advanced";
			}
			if(item2_isText)
			{
				item2.antiAliasType = "advanced";
			}
			
			item1_isText = item2_isText = false;
		}
		
		private function findAngle(item1, item2, collisionPoint):Number
		{
			if((item2.width * item2.height) > (item1.width * item1.height))
			{
				var rowWidth:uint = Math.round(item1.width);
				var columnHeight:uint = Math.round(item1.height);
				var center:Point = new Point((item1.width >> 1), (item1.height >> 1));
				var pixels:ByteArray = pixels2;
			}
			else
			{
				rowWidth = Math.round(item2.width);
				columnHeight = Math.round(item2.height);
				center = new Point((item2.width >> 1), (item2.height >> 1));
				pixels = pixels1;
			}

			var collisionY = collisionPoint / rowWidth, collisionX = collisionPoint % rowWidth;
			
			collisionX = collisionX != 0 ? (collisionX >> 5) * rowWidth : 0;

			if((collisionX == 0) && (collisionY == 0))
			{
				collisionX = collisionY = 1;
			}
			
			if((item2.width * item2.height) > (item1.width * item1.height))
			{
				transMatrix2.tx += (center.x);
				transMatrix2.ty += (center.y);
				bmdResample = new BitmapData(item1.width * 2, item1.height * 2, true, 0x00FFFFFF);
				bmdResample.draw(item2, transMatrix2, colorTransform2, null, null, true);
				pixels = bmdResample.getPixels(new Rectangle(0, 0, bmdResample.width, bmdResample.height));
			}
			else
			{
				transMatrix1.tx += center.x;
				transMatrix1.ty += center.y;
				bmdResample = new BitmapData(item2.width * 2,item2.height * 2, true, 0x00FFFFFF);
				bmdResample.draw(item1, transMatrix1, colorTransform1, null, null, true);
				pixels = bmdResample.getPixels(new Rectangle(0, 0, bmdResample.width, bmdResample.height));
			}

			center.x = (bmdResample.width >> 1);
			center.y = (bmdResample.height >> 1);
			
			columnHeight = Math.round(bmdResample.height);
			rowWidth = Math.round(bmdResample.width);
			
			var pixel:uint, thisAlpha:uint, lastAlpha:int, edgeArray:Array = new Array();

			for(var j:uint = 0; j < columnHeight; j++)
			{
				var k:uint = j * 4 * rowWidth;
				pixels.position = k;
				lastAlpha = -1;
				while(k < ((j + 1) * rowWidth * 4))
				{
					k = pixels.position;
					
					try
					{
						pixel = pixels.readUnsignedInt();
					}
					catch(e:EOFError)
					{
						break;
					}
					
					
					thisAlpha = pixel >> 24 & 0xFF;
					
					if(lastAlpha == -1)
					{
						lastAlpha = thisAlpha;
					}
					else
					{
						if(thisAlpha > _alphaThreshold)
						{
							var colorFlag:Boolean = false;
							if(colorExclusionArray.length)
							{
								var red1:uint = pixel >> 16 & 0xFF, green1:uint = pixel >> 8 & 0xFF, blue1:uint = pixel & 0xFF;
								
								var a:uint, r:uint, g:uint, b:uint, item1Flags:uint;
								
								var numColors:uint = colorExclusionArray.length;
								for(var n:uint = 0; n < numColors; n++)
								{
									a = colorExclusionArray[n].color >> 24 & 0xFF;
									r = colorExclusionArray[n].color >> 16 & 0xFF;
									g = colorExclusionArray[n].color >> 8 & 0xFF;
									b = colorExclusionArray[n].color & 0xFF;
									
									item1Flags = 0;
									if((blue1 >= b - colorExclusionArray[n].blue) && (blue1 <= b + colorExclusionArray[n].blue))
									{
										item1Flags++;
									}
									if((green1 >= g - colorExclusionArray[n].green) && (green1 <= g + colorExclusionArray[n].green))
									{
										item1Flags++;
									}
									if((red1 >= r - colorExclusionArray[n].red) && (red1 <= r + colorExclusionArray[n].red))
									{
										item1Flags++;
									}
									if((thisAlpha >= a - colorExclusionArray[n].alpha) && (thisAlpha <= a + colorExclusionArray[n].alpha))
									{
										item1Flags++;
									}									
									if(item1Flags == 4)
									{
										colorFlag = true;
									}
								}
							}
							
							if(!colorFlag)
							{
								edgeArray.push(k / 4);
							}
						}
					}
				}
			}
			
			var edgePoint:uint, edgeY:uint, edgeX:uint, angleArray:Array = new Array(), slope:Point, numYAdjusted:uint = 0, numXAdjusted:uint = 0, slopeArray:Array = new Array(), numEdges:int = edgeArray.length;

			for(j = 0; j < numEdges; j++)
			{
				edgePoint = edgeArray[j];
				edgeY = edgePoint / rowWidth;
				edgeX = edgePoint % rowWidth;
				
				edgeX = edgeX != 0 ? (edgeX / bmdResample.width) * rowWidth : 0;

				slope = new Point((edgeX - center.x), (center.y - edgeY));
				
				slopeArray.push(slope);
			}

			var slopeYAvg:Number = 0, slopeXAvg:Number = 0, numSlopes:int = slopeArray.length;

			for(j = 0; j < numSlopes; j++)
			{
				slopeYAvg += slopeArray[j].y;
				slopeXAvg += slopeArray[j].x;
			}			

			var average:Number = returnDegrees(Math.atan2(slopeYAvg, slopeXAvg));

			average = ~average + 1;
			
			average = _returnAngleType == "RADIANS" ? returnRadians(average) : average;
			
			return average;
			
		}
		
		private function returnDegrees(rads:Number):Number
		{
			var degs:Number = rads * 180 / Math.PI;
			return degs;
		}
		
		private function returnRadians(degs:Number):Number
		{
			var rads:Number = degs * Math.PI / 180;
			return rads;
		}
		
		public function set alphaThreshold(theAlpha:Number):void
		{
			if((theAlpha <= 1) && (theAlpha >= 0))
			{
				_alphaThreshold = theAlpha * 255;
			}
			else
			{
				throw new Error("alphaThreshold expects a value from 0 to 1");
			}
		}
		
		public function get alphaThreshold():Number
		{
			return _alphaThreshold;
		}
		
		public function set returnAngle(option):void
		{
			if(typeof(option) == "boolean")
			{
				_returnAngle = option;
			}
			else
			{
				throw new Error("returnAngle expects a Boolean value (true/false)");
			}
		}
		
		public function get returnAngle():Boolean
		{
			return _returnAngle;
		}
		
		public function set returnAngleType(returnType:String):void
		{
			returnType = returnType.toUpperCase();
			
			switch (returnType)
			{
				case "DEGREES" :
				case "DEGREE" :
				case "DEG" :
				case "DEGS" :
					_returnAngleType = "DEGREES";
					break;
				case "RADIANS" :
				case "RADIAN" :
				case "RAD" :
				case "RADS" :
					_returnAngleType = "RADIANS";
					break;
				default :
					throw new Error("returnAngleType expects 'DEGREES' or 'RADIANS'");
					break;
			}
		}
		
		public function get returnAngleType():String
		{
			return _returnAngleType;
		}
		
		public function get numChildren():uint
		{
			return objectArray.length;
		}
	}
}