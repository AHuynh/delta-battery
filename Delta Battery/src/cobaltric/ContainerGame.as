package cobaltric
{	
	import deltabattery.ABST_Manager;
	import deltabattery.ManagerMissile;
	import deltabattery.ManagerExplosion;
	import deltabattery.Turret;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import org.flintparticles.twoD.renderers.DisplayObjectRenderer;
	
	/**
	 * ...
	 * @author Alexander Huynh
	 */
	public class ContainerGame extends ABST_Container
	{
		public var rcl:RightClickListener;
		
		public var game:Game;
		public var turret:Turret;

		public var renderer:DisplayObjectRenderer;
		
		private var managers:Array;
		private var manLen:int;
		public var manMiss:ManagerMissile;
		public var manExpl:ManagerExplosion;
	
		public function ContainerGame()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			addEventListener(Event.REMOVED_FROM_STAGE, destroy);
			addEventListener(MouseEvent.MOUSE_MOVE, updateMouse);
			
			stage.showDefaultContextMenu = false;
			
			manExpl = new ManagerExplosion(this);
			manMiss = new ManagerMissile(this, manExpl);
			
			managers = [manMiss, manExpl];
			manLen = managers.length - 1;
	
			game = new Game();
			addChild(game);
			
			rcl = new RightClickListener();
			game.addChild(rcl);
			
			turret = new Turret(this, game.mc_turret);
			turret.updateMouse();
			
			renderer = new DisplayObjectRenderer();
			game.c_main.addChild(renderer);
			renderer.x += 380;		// TODO fix
			renderer.y -= 190;
		}
		
		
		override public function step():Boolean
		{
			for (var i:int = manLen; i >= 0; i--)
				managers[i].step();
			
			return false;
		}
		
		protected function updateMouse(e:MouseEvent):void
		{
			turret.updateMouse();
		}
		
		protected function getRand(min:Number = 0, max:Number = 1):Number   
		{  
			return (Math.random() * (max - min + 1)) + min;  
		} 
		
		private function destroy(e:Event):void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			removeEventListener(MouseEvent.MOUSE_MOVE, updateMouse);
		}
	}
}
