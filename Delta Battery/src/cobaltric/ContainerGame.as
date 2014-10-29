package cobaltric
{	
	import deltabattery.Armory;
	import deltabattery.managers.ABST_Manager;
	import deltabattery.managers.AutoPlayer;
	import deltabattery.managers.ManagerArtillery;
	import deltabattery.managers.ManagerBullet;
	import deltabattery.managers.ManagerMissile;
	import deltabattery.managers.ManagerExplosion;
	import deltabattery.managers.ManagerParticle;
	import deltabattery.managers.ManagerWave;
	import deltabattery.projectiles.ABST_Bullet;
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
		public var turretGrace:int;			// if not 0, don't let things fire (i.e. right after game starts)
		
		public var gameActive:Boolean;		// TRUE if game is active (ex: unpaused)
		
		public var tutorialFlag:Boolean;	// TRUE if day 1 chosen and tutorial didn't show
		public var infoFlag:Boolean;		// TRUE if info box at new wave needs to show
		
		private var managers:Array;			// array of all managers
		private var manLen:int;				// length of the manager array
		public var manPart:ManagerParticle;	// managers for specific ABSTract classes
		public var manWave:ManagerWave;
		public var manMiss:ManagerMissile;
		public var manArty:ManagerArtillery;
		public var manBull:ManagerBullet;
		public var manExpl:ManagerExplosion;
		
		public var money:int;				// actual money
		private var moneyDisplay:int;		// displayed money (for 'increasing' slack effect)
		private const MONEY_DELTA:int = 11;	// rate to change displayed money
		
		public var cityHP:Number;			// HP of city, 0 is destroyed (uses primary HP bar)
		public var cityHPMax:Number;		// max HP of city
		
		private var cityHPSlack:Number;		// displayed HP of city (uses secondary 'ghost' HP bar)
		private var cityHPCounter:int;		// delay before slack decreases
		
		private var intermission:int;		// counter for in-between waves
		
		//private var ai:AutoPlayer;		// TEMP AutoPlayer
		public var mx:Number = 0;
		public var my:Number = 0;
		
		private var shop:MovieClip;			// reference to the shop MovieClip
		public var armory:Armory;
		
		private var startWave:int = 1;
	
		public function ContainerGame(_startWave:int = 1)
		{
			super();
			startWave = _startWave;
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		/*	Sets up the game.
		 * 	Called after this Container is added to the stage.
		 */
		private function init(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			addEventListener(Event.REMOVED_FROM_STAGE, destroy);
			addEventListener(MouseEvent.MOUSE_MOVE, updateMouse);
			
			// disable right click menu
			stage.showDefaultContextMenu = false;
	
			// setup the Game SWC
			game = new Game();
			addChild(game);
			game.x -= 129;
			game.y -= 446;
			//game.mc_gui.mc_statusCenter.tf_status.text = "Wave 1 begun!";
			game.mc_gui.mc_statusCenter.visible = false;
			game.mc_gui.mc_statusHuge.visible = false;
			
			// initialize managers
			manPart = new ManagerParticle(this);
			manMiss = new ManagerMissile(this);
			manArty = new ManagerArtillery(this);
			manBull = new ManagerBullet(this);
			manExpl = new ManagerExplosion(this);
			manWave = new ManagerWave(this, startWave);
			managers = [manPart, manWave, manArty, manMiss, manBull, manExpl];
			manLen = managers.length - 1;
			
			// setup the Turret
			turret = new Turret(this, game.mc_turret);
			turret.updateMouse();
			turret.turret.mc_cannon.deltaStrike.visible = false;
			
			// setup city
			cityHP = cityHPMax = cityHPSlack = 100;
			
			// setup autoplayer
			//ai = new AutoPlayer(this, manMiss);
			
			// setup shop
			shop = game.mc_gui.shop;
			shop.visible = false;
			shop.btn_nextDay.addEventListener(MouseEvent.CLICK, onShopDone);
			
			armory = new Armory(this);
			
			// setup tutorial
			tutorialFlag = true;						// TODO set based on chosen day
			game.mc_gui.tutorial.gotoAndPlay("in");		// TODO set
			gameActive = false;
			
			// new wave indicator
			infoFlag = true;
			game.mc_gui.newEnemy.mc.gotoAndStop(manWave.wave >= 5 ? 5 : manWave.wave);
			game.mc_gui.newEnemy.mc.btn_start.addEventListener(MouseEvent.CLICK, infoAck);
		}
		
		// called by Engine every frame
		override public function step():Boolean
		{
			if (tutorialFlag)
			{
				if (game.mc_gui.tutorial.mc.currentFrame == game.mc_gui.tutorial.mc.totalFrames)
				{
					game.mc_gui.tutorial.gotoAndPlay("out");
					tutorialFlag = false;
					game.mc_gui.newEnemy.gotoAndPlay("in");
				}
				return false;
			}
			else if (infoFlag)
			{
				gameActive = false;
				return false;
			}
			
			if (turretGrace > 0)
				turretGrace--;
			
			// delay between wave success and showing the shop
			if (intermission > 0)
			{
				if (--intermission == 0)
				{
					game.mc_gui.shop.visible = true;
					game.mc_gui.mc_statusHuge.visible = false;
				}
			}
			
			if (gameActive)
				turret.step();		// update the Turret
			updateMoney();
			updateHP();
			//ai.step();
			
			// update each manager
			for (var i:int = manLen; i >= 0; i--)
				managers[i].step();
			
			return false;
		}
		
		private function infoAck(e:MouseEvent):void
		{
			game.mc_gui.newEnemy.gotoAndPlay("out");
			infoFlag = false;
			gameActive = true;
		}
		
		// updates city's ghost HP bar
		private function updateHP():void
		{
			if (cityHPSlack == cityHP) return;
			
			if (cityHPCounter > 0)
			{
				cityHPCounter--;
				return;
			}
			
			if (--cityHPSlack < cityHP)
				cityHPSlack = cityHP;

			var life:Number = cityHPSlack / cityHPMax;
			game.mc_gui.mc_health.secondary.x = 74.75 - (1 - life) * 149.5;		// update health bar (secondary)
		}
		
		/**	Damage the city by m's damage.
		 * 	Called by an ABST_Missile.
		 * 
		 * 	@m		The missile that is damaging the city
		 */
		public function damageCity(param:*):void
		{
			var life:Number;
			if (param is ABST_Missile) {
				cityHP -= param.damage;
				cityHPCounter = 30;		// reset the slack counter
			
				life = cityHP / cityHPMax;
				game.mc_gui.mc_health.primary.x = 74.75 - (1 - life) * 149.5;		// update health bar (primary)
			} else if (param is ABST_Bullet) {
				cityHP -= param.damage;
				cityHPCounter = 30;		// reset the slack counter
			
				life = cityHP / cityHPMax;
				game.mc_gui.mc_health.primary.x = 74.75 - (1 - life) * 149.5;		// update health bar (primary)
			}
			
			if (cityHP <= 0)
			{
				cityHP = 0;
				game.city.gotoAndStop(game.city.totalFrames);
				//completed = true;		// TODO game over
			}
			else		// update the visual state of the city
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
		
		// called by the "NEXT WAVE" button in the shop
		private function onShopDone(e:MouseEvent):void
		{
			manWave.startWave();
			game.mc_gui.shop.visible = false;
			infoFlag = true;
			game.mc_gui.newEnemy.gotoAndPlay("in");
			game.mc_gui.newEnemy.mc.gotoAndStop(manWave.wave >= 5 ? 5 : manWave.wave);		// TODO change 5 (max wave)
		}
		
		// end the current wave, enabling the shop, etc.
		// called after the intermission finishes
		public function endWave():void
		{
			game.mc_gui.tf_wave.text = manWave.wave;
			//game.mc_gui.mc_statusCenter.tf_status.visible = true;
			//game.mc_gui.mc_statusCenter.tf_status.text = "Wave " + (manWave.wave - 1) + " complete!";
			game.mc_gui.mc_statusHuge.visible = true;
			game.mc_gui.mc_statusHuge.tf_statusHuge.text = "Wave " + (manWave.wave - 1) + " complete!";
			intermission = 120;
			gameActive = false;
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
			if (!gameActive) return;

			mx = mouseX - game.x;
			my = mouseY - game.y;
			turret.updateMouse();			
		}
		
		// get a list of all live projectiles
		public function getProjectileArray():Array
		{
			var a:Array = [];
			return a.concat(manMiss.objArr).concat(manArty.objArr);
		}
		
		/*
		public function overrideMouse(tgtX:Number, tgtY:Number):void
		{
			mx = tgtX;
			my = tgtY;
			turret.updateMouse();	
		}*/
		
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
