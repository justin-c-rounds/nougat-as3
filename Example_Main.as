package {
	
	import org.justincrounds.actionscript.*;
	import flash.display.MovieClip;
	import flash.text.Font;
        import nl.demonsters.debugger.MonsterDebugger;
        
        /* SWF parameters go here. */
	[SWF(width='640', height='480', backgroundColor='#000000', frameRate='60')]
	
	public class Example_Main extends MovieClip {
		
		/* Every class to be instantiated via XML should be added to the following array. */
		private var classArray:Array = [TextDisplay];
		
		/* Embeds. */
		[Embed(source='DejaVuSans.ttf', fontName='DejaVuSans', mimeType='application/x-font-truetype', embedAsCFF='false')]
		internal static const DejaVuSans:Class;
		Font.registerFont(DejaVuSans);
		
		private var controller:Controller = new Controller();
		private var debugger:MonsterDebugger;
		
		public function Example_Main() {
			
			if (CONFIG::development) {
				debugger = new MonsterDebugger(this);
				controller.addEventListener("debug", monsterDebug, false, 0, true);
			}
			
			/* Stage setup. */
			stage.scaleMode = "showAll";
			stage.quality = "low";
			stage.showDefaultContextMenu = false;
			
			/* Include build data. */
			include "Example_Main.xml"
			controller.model.blueprint = xml;
			
			/* Add view. */
			addChild(controller.view);
			
			/* Uncomment the line below to enable default keyboard directional controls via Iain Lobb's gamepad code. */
			//controller.view.gamepad.useWASD();
			
			/* Start application. */
			controller.broadcast("LOAD SCENARIO", "game start");
		}
		
		private function monsterDebug(e:BroadcastEvent):void {
			MonsterDebugger.trace(this, e.object);
		}
	}
}
