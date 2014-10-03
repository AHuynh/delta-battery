package cobaltric
{	
	import deltabattery.managers.ABST_Manager;
	import deltabattery.managers.AutoPlayer;
	import deltabattery.managers.ManagerArtillery;
	import deltabattery.managers.ManagerBullet;
	import deltabattery.managers.ManagerMissile;
	import deltabattery.managers.ManagerExplosion;
	import deltabattery.managers.ManagerParticle;
	import deltabattery.managers.ManagerWave;
	import deltabattery.Turret;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * Primary game container and controller
	 * @author Alexander Huynh
	 */
	public class ContainerGame extends ABST_Container
	{		
		public var game:Game;				// the Game SWC, containing all the base assets
		public var turret:Turret;			// the player's turret
		
		private var managers:Array;			// array of all managers
		private var manLen:int;				// length of the manager array
		public var manPart:ManagerParticle;
		public var manWave:ManagerWave;
		public var manMiss:ManagerMissile;
		public var manArty:ManagerArtillery;
		public var manBull:ManagerBullet;
		public var manExpl:ManagerExplosion;
		
		public var money:int;				// actual money
		private var moneyDisplay:int;		// displayed money
		private const MONEY_DELTA:int = 11;	// rate to change displayed money
		
		private var intermission:int;		// counter for in-between waves
		
		private var ai:AutoPlayer;			// TEMP AutoPlayer
		public var mx:Number = 0;
		public var my:Number = 0;
	
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
	
			// setup the Game SWC
			game = new Game();
			addChild(game);
			game.x -= 15;
			game.mc_gui.tf_status.text = "Wave 1 begun!";
			game.mc_gui.mc_statusHuge.visible = false;
			
			// initialize managers
			manPart = new ManagerParticle(this);
			manMiss = new ManagerMissile(this);
			manArty = new ManagerArtillery(this);
			manBull = new ManagerBullet(this);
			manExpl = new ManagerExplosion(this);
			manWave = new ManagerWave(this);
			managers = [manPart, manWave, manArty, manMiss, manBull, manExpl];
			manLen = managers.length - 1;
			
			// setup the Turret
			turret = new Turret(this, game.mc_turret);
			turret.updateMouse();
			
			// setup autoplayer
			//ai = new AutoPlayer(this, manMiss);
			
			//game.soundBox.gotoAndPlay("first");
		}
		
		// called by Engine every frame
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
				return manWave.wave == 3;
			}
			
			turret.step();
			// update each manager
			for (var i:int = manLen; i >= 0; i--)
				managers[i].step();
			updateMoney();
			
			//ai.step();
			
			return false;
		}
		
		/**	End the current wave, enabling the shop, etc.
		 * 
		 */
		public function endWave():void
		{
			game.mc_gui.tf_wave.text = manWave.wave;
			game.mc_gui.tf_status.visible = true;
			game.mc_gui.tf_status.text = "Wave " + (manWave.wave - 1) + " complete!";
			game.mc_gui.mc_statusHuge.visible = true;
			game.mc_gui.mc_statusHuge.tf_statusHuge.text = "Wave " + (manWave.wave - 1) + " complete!";
			intermission = 120;
			
			//if (manWave.wave == 2)
				//game.soundBox.gotoAndPlay("second");
		}
		
		// updates the displayed money to match the actual money
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
		
		// changes the money by amount
		public function addMoney(amount:int):Boolean
		{
			if (money + amount < 0)
				return false;
			money += amount;
			return true;
		}
		
		// called when the mouse is moved
		protected function updateMouse(e:MouseEvent):void
		{
			mx = mouseX;
			my = mouseY;
			turret.updateMouse();			
		}
		
		public function overrideMouse(tgtX:Number, tgtY:Number):void
		{
			mx = tgtX;
			my = tgtY;
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
