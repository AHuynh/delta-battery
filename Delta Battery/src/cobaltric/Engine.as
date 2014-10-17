package cobaltric
{
	import flash.display.MovieClip;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
	/**
	 * Engine.as
	 * 
	 * Primary game loop event firer and state machine.
	 * 
	 * @author Alexander Huynh
	 */
	public class Engine extends MovieClip
	{
		private var gameState:int;				// 0:Intro, 1:Game, 2:Outro
		private var container:ABST_Container;	// the currently active container
		
		public var startWave:int = 1;
		
		public function Engine()
		{
			gameState = 0;
			container = new ContainerIntro(this);
			addChild(container);

			// center the container
			container.x = 0;//stage.width * .5;
			container.y = 0;//stage.height * .5;
			
			addEventListener(Event.ENTER_FRAME, step);
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		public function step(e:Event):void
		{
			if (!container.step())
				return;

			removeChild(container);
			switch (gameState)
			{
				case 0:
					container = new ContainerGame(startWave);
					gameState++;
					trace("Intro Container completed!");
				break;
				case 1:
					container = new ContainerOutro();
					gameState++;
					trace("Game Container completed!");
				break;
				case 2:
					gameState = 0;
					container = new ContainerIntro(this);
					trace("Outro Container completed!");
				break;
			}
			
			addChild(container);
			container.x = stage.width * .5;
			container.y = stage.height * .5;
		}
		
		private function onAddedToStage(e:Event):void
		{
			container.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			container.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		}
		
		private function onKeyPress(e:KeyboardEvent):void
		{
			if (!container.stage) return;
			if (e.keyCode == 76)		// -- 1
				container.stage.quality = StageQuality.LOW;
			else if (e.keyCode == 77)	// -- 2
				container.stage.quality = StageQuality.MEDIUM;
			else if (e.keyCode == 72)	// -- 3
				container.stage.quality = StageQuality.HIGH;
		}
	}
	
}
