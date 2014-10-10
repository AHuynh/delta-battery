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
	import deltabattery.projectiles.ABST_Missile;
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
		
		public var cityHP:Number;
		public var cityHPMax:Number;
		
		private var intermission:int;		// counter for in-between waves
		
		private var ai:AutoPlayer;			// TEMP AutoPlayer
		public var mx:Number = 0;
		public var my:Number = 0;
		
		private var shop:MovieClip;
	
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
			//game.mc_gui.mc_statusCenter.tf_status.text = "Wave 1 begun!";
			game.mc_gui.mc_statusCenter.visible = false;
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
			
			// setup city
			cityHP = cityHPMax = 100;
			game.mc_gui.mc_health.secondary.visible = false;		// TEMPORARY
			
			// setup autoplayer
			//ai = new AutoPlayer(this, manMiss);
			
			// setup shop
			shop = game.mc_gui.shop;
			shop.visible = false;
			shop.btn_nextDay.addEventListener(MouseEvent.CLICK, onShopDone);
		}
		
		// called by Engine every frame
		override public function step():Boolean
		{
			if (intermission > 0)
			{
				if (--intermission == 0)
				{
					game.mc_gui.shop.visible = true;
					game.mc_gui.mc_statusHuge.visible = false;
				}
			}
			
			turret.step();
			// update each manager
			for (var i:int = manLen; i >= 0; i--)
				managers[i].step();
			updateMoney();
			
			//ai.step();
			
			return false;
		}
		
		public function damageCity(m:ABST_Missile):void
		{
			cityHP -= m.damage;
			
			var life:Number = cityHP / cityHPMax;
			game.mc_gui.mc_health.primary.x = 74.75 - (1 - life) * 149.5;		// update health bar
			
			if (cityHP <= 0)
			{
				cityHP = 0;
				game.city.gotoAndStop(game.city.totalFrames);
				// TODO game over
			}
			else
			{
				if (life < .35)
					game.city.gotoAndStop(4);
				else if (life < .5)
					game.city.gotoAndStop(3);
				else if (life < .85)
					game.city.gotoAndStop(2);
				else
					game.city.gotoAndStop(1);
				// TODO make into a function?
				//game.city.gotoAndStop(Math.round((cityHP / cityHPMax) * game.city.totalFrames));
			}
		}
		
		// called by a button in the shop
		private function onShopDone(e:MouseEvent):void
		{
			manWave.startWave();
			//game.mc_gui.mc_statusCenter.tf_status.text = "Wave " + (manWave.wave) + " begin!";	
			game.mc_gui.shop.visible = false;
		}
		
		/**	End the current wave, enabling the shop, etc.
		 * 
		 */
		public function endWave():void
		{
			game.mc_gui.tf_wave.text = manWave.wave;
			//game.mc_gui.mc_statusCenter.tf_status.visible = true;
			//game.mc_gui.mc_statusCenter.tf_status.text = "Wave " + (manWave.wave - 1) + " complete!";
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
