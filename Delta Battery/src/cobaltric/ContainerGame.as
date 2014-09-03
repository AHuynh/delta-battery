package cobaltric
{	
	import deltabattery.ABST_Manager;
	import deltabattery.ManagerBullet;
	import deltabattery.ManagerMissile;
	import deltabattery.ManagerExplosion;
	import deltabattery.ManagerWave;
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
		public var game:Game;
		public var turret:Turret;

		public var renderer:DisplayObjectRenderer;
		
		private var managers:Array;
		private var manLen:int;
		public var manWave:ManagerWave;
		public var manMiss:ManagerMissile;
		public var manBull:ManagerBullet;
		public var manExpl:ManagerExplosion;
		
		public var money:int;				// actual money
		private var moneyDisplay:int;		// displayed money
		private const MONEY_DELTA:int = 11;
		
		private var intermission:int;
	
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
			
			manMiss = new ManagerMissile(this);
			manBull = new ManagerBullet(this, manMiss);
			manExpl = new ManagerExplosion(this, manMiss);
			manWave = new ManagerWave(this, manMiss);
			
			managers = [manWave, manMiss, manBull, manExpl];
			manLen = managers.length - 1;
	
			game = new Game();
			addChild(game);
			game.x -= 15;
			game.mc_gui.tf_status.text = "Wave 1 begun!";
			game.mc_gui.mc_statusHuge.visible = false;
			
			turret = new Turret(this, game.mc_turret);
			turret.updateMouse();
			
			renderer = new DisplayObjectRenderer();
			game.c_main.addChild(renderer);
			renderer.x += 380;		// TODO fix
			renderer.y -= 190;
		}
		
		
		override public function step():Boolean
		{
			if (intermission > 0)
			{
				if (--intermission == 0)
				{
					manWave.startWave();
					game.mc_gui.tf_status.text = "Wave " + (manWave.wave) + " begin!";	
					game.mc_gui.mc_statusHuge.visible = false;
				}
				return false;
			}
			
			turret.step();
			for (var i:int = manLen; i >= 0; i--)
				managers[i].step();
			updateMoney();
			
			return false;
		}
		
		public function endWave():void
		{
			game.mc_gui.tf_wave.text = manWave.wave;
			game.mc_gui.tf_status.visible = true;
			game.mc_gui.tf_status.text = "Wave " + (manWave.wave - 1) + " complete!";
			game.mc_gui.mc_statusHuge.visible = true;
			game.mc_gui.mc_statusHuge.tf_statusHuge.text = "Wave " + (manWave.wave - 1) + " complete!";
			intermission = 120;
		}
		
		private function updateMoney():void
		{
			if (moneyDisplay == money)
				return;

			var delta:int = moneyDisplay - money;
			if (Math.abs(delta) < MONEY_DELTA)
				moneyDisplay = money;
			else
				moneyDisplay += (delta > 0 ? -1 : 1) * MONEY_DELTA;
			game.mc_gui.tf_money.text = moneyDisplay;
		}
		
		public function addMoney(amount:int):Boolean
		{
			if (money + amount < 0)
				return false;
			money += amount;
			return true;
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
