package deltabattery.managers {
	import cobaltric.ABST_Container;
	import cobaltric.ContainerGame;
	import deltabattery.projectiles.ABST_Missile;
	import flash.geom.Point;
	
	/**	Directs enemy spawns throughout the game
	 *
	 * @author Alexander Huynh
	 */
	public class ManagerWave extends ABST_Manager 
	{
		private var manMiss:ManagerMissile;
		private var manArty:ManagerArtillery;
		public var wave:int;

		public var waveActive:Boolean;
		public var enemiesRemaining:int;
		
		private var spawnDelay:int;		// counter
		private var spawnMin:int;		// counter reset value (minimum)
		private var spawnMax:int;		// maximum counter value
		private var spawnRandom:Number;
		
		private var spawnX:int = -420;
		private var spawnY:int = -200;
		private var spawnVarianceX:int = 20;
		private var spawnVarianceY:int = 50;
		
		private var targetX:int = 390;
		private var targetY:int = 150;
		private var targetVarianceX:int = 80;
		private var targetVarianceY:int = 30;
		
		private var dayFlag:int = 0;	// 0 day, 1 sunset, 2 night
		
		public function ManagerWave(_cg:ContainerGame, _wave:int = 1)
		{
			super(_cg);
			
			trace("Starting with wave: " + _wave);
			
			manMiss = cg.manMiss;
			manArty = cg.manArty;
			wave = _wave;
			
			// TODO change later
			startWave();
		}
		
		public function startWave():void
		{
			waveActive = true;
			dayFlag = 0;
			advanceTime();		// reset sky/ocean
			
			switch (wave)
			{
				case 1:
					enemiesRemaining = 4;
					
					spawnDelay = 30 * 2;		// 2 seconds initial delay
					spawnMin = 30;				// 1 second minimum
					spawnMax = 30 * -1;			// 1 second maximum
					spawnRandom = .98;
				break;
				case 2:
					enemiesRemaining = 6;
					
					spawnDelay = 30 * 2;
					spawnMin = 20;
					spawnMax = 25 * -1;
					spawnRandom = .98;
				break;
				case 3:
					enemiesRemaining = 10;
					
					spawnDelay = 30 * 2;
					spawnMin = 15;
					spawnMax = 20 * -1;
					spawnRandom = .97;
				break;
				default:		// crazy demo
					enemiesRemaining = 80;
					
					spawnDelay = 30 * 1;
					spawnMin = 3;
					spawnMax = -15;
					spawnRandom = .3;
		
					spawnX = -400;
					spawnY = -240;
					spawnVarianceX = 300;
			}
		}
		
		// "day"		day -> sunset
		// "sunset"		sunset -> night
		public function advanceTime(t:String = null):void
		{
			if (!t)
			{
				cg.game.bg.sky.gotoAndStop(1);
				cg.game.bg.ocean.gotoAndStop(1);
				return;
			}
			cg.game.bg.sky.gotoAndPlay(t);
			cg.game.bg.ocean.gotoAndPlay(t);
		}
		
		public function endWave():void
		{
			waveActive = false;
			wave++;
			cg.endWave();
		}
		
		override public function step():void
		{
			if (!waveActive) return;
			
			if (enemiesRemaining == 0)
			{
				//if (!manMiss.hasObjects())		// TODO
				var done:Boolean = true;
				
				var proj:Array = cg.getProjectileArray();
				var p:ABST_Missile;
				for (var i:int = proj.length - 1; i >= 0; i--)
				{
					p = proj[i];
					if (p.type == 0)
					{
						done = false;
						break;
					}
				}
				if (done)
					endWave();
				return;
			}

			spawnDelay--;
			// TODO make better, loool
			if ((spawnDelay <= 0 && Math.random() > spawnRandom) || spawnDelay < spawnMax)
			{
				if (wave == 3 || (wave > 2 && Math.random() > .6))		// TODO remove magic number .6
				{
				manArty.spawnProjectile("standard", new Point(spawnX + -2 * spawnVarianceX + getRand(0, spawnVarianceX),
															  spawnY + -2 * spawnVarianceY + getRand(0, spawnVarianceY) + 100),
													new Point(targetX + -2 * targetVarianceX + getRand(0, targetVarianceX),
														 	  targetY + -2 * targetVarianceY + getRand(0, targetVarianceY)));
				
				}
															  
				else if (wave != 3)
				{
				manMiss.spawnProjectile("standard", new Point(spawnX + -2 * spawnVarianceX + getRand(0, spawnVarianceX),
															  spawnY + -2 * spawnVarianceY + getRand(0, spawnVarianceY)),
													new Point(targetX + -2 * targetVarianceX + getRand(0, targetVarianceX),
														 	  targetY + -2 * targetVarianceY + getRand(0, targetVarianceY)));
				}											  
				
				spawnDelay = spawnMin;
				enemiesRemaining--;
				cg.game.mc_gui.mc_statusCenter.tf_status.text = enemiesRemaining + " projectile(s) left."
				
				// TODO change hardcoded enemiesRemaining to variables
				if (dayFlag == 0 && enemiesRemaining == 5)
				{
					dayFlag++;
					advanceTime("day");
				}
				else if (dayFlag == 1 && enemiesRemaining <= 2)
				{
					if (cg.game.bg.ocean.currentFrame < 152)		// magic number :c
						return;
					dayFlag++;
					advanceTime("sunset");
				}

			}
			if (spawnDelay < spawnMax)
				spawnDelay = spawnMin;
		}
	}
}