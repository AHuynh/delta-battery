package cobaltric
{	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Alexander Huynh
	 */
	public class ContainerGame extends ABST_Container
	{
		public var game:Game;
	
		public function ContainerGame()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			game = new Game();
			addChild(game);
		}
		
		
		override public function step():Boolean
		{
			
			return false;
		}
		
		
		protected function getRand(min:Number = 0, max:Number = 1):Number   
		{  
			return (Math.random() * (max - min + 1)) + min;  
		} 
		
	}
}
