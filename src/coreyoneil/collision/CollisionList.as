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
	
	public class CollisionList extends CDK
	{
		public function CollisionList(target, ... objs):void 
		{
			addItem(target);
			
			for(var i:uint = 0; i < objs.length; i++)
			{
				addItem(objs[i]);
			}
		}
		
		public function checkCollisions():Array
		{
			clearArrays();
			
			var NUM_OBJS:uint = objectArray.length;
			var item1 = objectArray[0];
			for(var i:uint = 1; i < NUM_OBJS; i++)
			{
				var item2 = objectArray[i];
					
				if(item1.hitTestObject(item2))
				{
					objectCheckArray.push([item1,item2]);
				}
			}
			
			if(objectCheckArray.length)
			{
				NUM_OBJS = objectCheckArray.length;
				for(i = 0; i < NUM_OBJS; i++)
				{
					findCollisions(objectCheckArray[i][0], objectCheckArray[i][1]);
				}
			}
			
			return objectCollisionArray;
		}
		
		public function swapTarget(target):void
		{
			if(target is DisplayObject)
			{
				var _root = target.root;
				
				if(_root == null)
				{
					throw new Error("Items added for collision detection must be on the display list.");
				}
				else
				{
					objectArray[0] = target;
				}
			}
			else
			{
				throw new Error("Cannot swap target: " + target + " - item must be a Display Object.");
			}
		}
		
		public override function removeItem(obj):void 
		{
			var found:Boolean = false;
			var numObjs:int = objectArray.length;
			for(var i:uint = 0; i < numObjs; i++)
			{
				if(objectArray[i] == obj)
				{
					if(i == 0)
					{
						throw new Error("You cannot remove the target from CollisionList.  Use swapTarget to change the target.");
					}
					else
					{
						objectArray.splice(i, 1);
						found = true;
						break;
					}
				}
			}
			
			if(!found)
			{
				throw new Error(obj + " could not be removed - object not found in item list.");
			}
		}
	}
}