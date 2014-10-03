package deltabattery.managers {
	import cobaltric.ContainerGame;
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
		
		private var targetX:int = 370;
		private var targetY:int = 230;
		private var targetVarianceX:int = 100;
		private var targetVarianceY:int = 10;
		
		public function ManagerWave(_cg:ContainerGame, _wave:int = 1)
		{
			super(_cg);
			
			manMiss = cg.manMiss;
			manArty = cg.manArty;
			wave = _wave;
			
			// TODO change later
			startWave();
		}
		
		public function startWave():void
		{
			// TODO use switch on wave
			waveActive = true;
			
			switch (wave)
			{
				case 1:
					enemiesRemaining = 5;
					
					spawnDelay = 30 * 4;		// 2 seconds initial delay
					spawnMin = 30;				// 1 second minimum
					spawnMax = 30 * -1;			// 1 second maximum
					spawnRandom = .98;
				break;
				case 2:
					enemiesRemaining = 14;
					
					spawnDelay = 30 * 4;		// 2 seconds initial delay
					spawnMin = 20;				// .67 second minimum
					spawnMax = 30 * -1;			// 1 second maximum
					spawnRandom = .98;
				break;
				case 999:		// crazy demo
					enemiesRemaining = 60;
					
					spawnDelay = 30 * 4;
					spawnMin = 5;
					spawnMax = -15;
					spawnRandom = .3;
		
					spawnX = -400;
					spawnY = -240;
					spawnVarianceX = 300;
				break;
				default:
			}
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
				if (!manMiss.hasObjects())
					endWave();
				return;
			}

			spawnDelay--;
			if (spawnDelay <= 0 && Math.random() > spawnRandom)
			{
				if (wave > 1 && Math.random() > .6)		// TODO remove magic number .6
				{
				manArty.spawnProjectile("standard", new Point(spawnX + -2 * spawnVarianceX + getRand(0, spawnVarianceX),
															  spawnY + -2 * spawnVarianceY + getRand(0, spawnVarianceY) + 100),
													new Point(targetX + -2 * targetVarianceX + getRand(0, targetVarianceX),
														 	  targetY + -2 * targetVarianceY + getRand(0, targetVarianceY)));
				
				}
															  
				else
				{
				manMiss.spawnProjectile("standard", new Point(spawnX + -2 * spawnVarianceX + getRand(0, spawnVarianceX),
															  spawnY + -2 * spawnVarianceY + getRand(0, spawnVarianceY)),
													new Point(targetX + -2 * targetVarianceX + getRand(0, targetVarianceX),
														 	  targetY + -2 * targetVarianceY + getRand(0, targetVarianceY)));
				}											  
				
				spawnDelay = spawnMin;
				enemiesRemaining--;
				cg.game.mc_gui.tf_status.text = enemiesRemaining + " projectile(s) left."
			}
			if (spawnDelay < spawnMax)
				spawnDelay = spawnMin;
		}
	}
}