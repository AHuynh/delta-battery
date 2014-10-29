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
		
		private var spawnLoc:Object = new Object();
		/*	spawnLoc["type"] -> [null, [(x1, y1), (x2, y2)], null]
		 * 
		 * 	let arr be spawnLoc["type"]
		 * 	arr				null if not able to spawn in this wave
		 * 	arr[]			regions to spawn in
		 * 	arr[][0..1]		upper left and lower right corners of
		 * 					spawn region
		 */
		
		private var spawnType:Array;
		/*	chance (weights) of given projectile to spawn
		 * 	[missile, artillery, fast, big, cluster, LASM, bomber] ...
		 *      0         1        2    3      4	  5  	 6      9
		 */
		
		private var targetX:int = 390;
		private var targetY:int = 150;
		private var targetVarianceX:int = 80;
		private var targetVarianceY:int = 30;
		
		private var dayFlag:int = 0;	// 0 day, 1 sunset, 2 night
		
		// region helpers
		private const R_CORNER_SMALL:Array = [new Point( -450, -350), new Point( -410, -310)];
		private const R_CORNER_LARGE:Array = [new Point( -500, -400), new Point( -410, -310)];
		
		private const R_LEFT_TOP:Array = [new Point( -450, -300), new Point( -410, -150)];
		private const R_LEFT_LASM:Array = [new Point( -450, -250), new Point( -410, -150)];
		
		private const R_ARTY_NORM:Array = [new Point( -500, -170), new Point( -420, -220)];
		
		// param helpers
		private const P_FAST:Object = { explosionScale: .75 };
		private const P_BIG:Object = { explosionScale: 2.25 };
		
		public function ManagerWave(_cg:ContainerGame, _wave:int = 1)
		{
			super(_cg);
			
			manMiss = cg.manMiss;
			manArty = cg.manArty;
			wave = _wave;
			
			resetSpawnType();
			startWave();
		}
		
		public function startWave():void
		{
			waveActive = true;
			dayFlag = 0;
			advanceTime();		// reset sky/ocean
			resetSpawnType();	// reset probabilities of all projectiles spawning to 0
			
			switch (wave)
			{
				// standard missile
				case 1:
					enemiesRemaining = 8;
			
					// enable missiles - (corner)
					spawnLoc["missile"] = [R_LEFT_TOP];
					
					// set spawn probabilities
					spawnType[0] = 1;			// 100% missile
					
					spawnDelay = 30 * 2;		// 2 seconds initial delay
					spawnMin = 30 * 2;			// 2 seconds minimum
					spawnMax = -30 * 4;			// 4 seconds maximum
					spawnRandom = .98;
				break;
				// faster standard missile
				case 2:
					enemiesRemaining = 12;
					
					// set spawn probabilities
					spawnType[0] = 1;			// 100% missile
					
					spawnDelay = 30 * 2;
					spawnMin = 20;
					spawnMax = 25 * -1;
					spawnRandom = .98;
				break;
				// artillery
				case 3:
					enemiesRemaining = 10;
					
					// enable projectiles
					spawnLoc["artillery"] = [R_ARTY_NORM];
					
					// set spawn probabilities
					spawnType[1] = 1;			// 100% artillery
					
					spawnDelay = 30 * 2;
					spawnMin = 30 * 2 + 15;		// 2.5 seconds minimum
					spawnMax = -30 * 4;
					spawnRandom = .97;
				break;
				// missiles + artillery
				case 4:
					enemiesRemaining = 18;
					
					// enable projectiles
					spawnLoc["missile"] = [R_LEFT_TOP];
					spawnLoc["artillery"] = [R_ARTY_NORM];
					
					// set spawn probabilities
					spawnType[0] = 3;			// 75% missile
					spawnType[1] = 1;			// 25% artillery
					
					spawnDelay = 30 * 2;
					spawnMin = 30 * 2;			// 2 seconds minimum
					spawnMax = -30 * 3;			// 3 seconds maximum
					spawnRandom = .96;
				break;
				
				case 9:			// test
					enemiesRemaining = 4;
					
					// enable projectiles
					spawnLoc["cluster"] = [R_LEFT_TOP];
					
					// set spawn probabilities
					spawnType[4] = 1;			// 100% cluster
					
					spawnDelay = 0;
					spawnMin = 30 * 2;			// 2 seconds minimum
					spawnMax = -30 * 3;			// 3 seconds maximum
					spawnRandom = .96;
				break;
				case 8:			// test
					enemiesRemaining = 4;
					
					// enable projectiles
					spawnLoc["fast"] = [R_LEFT_TOP];
					
					// set spawn probabilities
					spawnType[2] = 1;			// 100% fast
					
					spawnDelay = 0;
					spawnMin = 30 * 2;			// 2 seconds minimum
					spawnMax = -30 * 3;			// 3 seconds maximum
					spawnRandom = .96;
				break;
				case 7:			// test
					enemiesRemaining = 4;
					
					// enable projectiles
					spawnLoc["bomber"] = [R_LEFT_LASM];
					
					// set spawn probabilities
					spawnType[6] = 1;			// 100% big
					
					spawnDelay = 0;
					spawnMin = 30 * 2;			// 2 seconds minimum
					spawnMax = -30 * 3;			// 3 seconds maximum
					spawnRandom = .96;
				break;
				case 10:			// test
					enemiesRemaining = 4;
					
					// enable projectiles
					spawnLoc["LASM"] = [R_LEFT_LASM];
					
					// set spawn probabilities
					spawnType[5] = 1;			// 100% LASM
					
					spawnDelay = 0;
					spawnMin = 30 * 2;			// 2 seconds minimum
					spawnMax = -30 * 3;			// 3 seconds maximum
					spawnRandom = .96;
				break;
				
				default:		// crazy demo
					enemiesRemaining = 80;
					
					// enable projectiles
					spawnLoc["missile"] = [R_LEFT_TOP];
					spawnLoc["artillery"] = [R_ARTY_NORM];
					
					// set spawn probabilities
					spawnType[0] = 1;			// 50% missile
					spawnType[1] = 1;			// 50% artillery
					
					spawnDelay = 30 * 1;
					spawnMin = 3;
					spawnMax = -15;
					spawnRandom = .3;
			}
		}
		
		// no argument	instantaneous day
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
			
			// if no more spawning, check if no enemy threats are left
			if (enemiesRemaining == 0)
			{
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
				switch (choose(spawnType))
				{
					// standard missile
					case 0:
						manMiss.spawnProjectile("standard", getSpawnLocation("missile"), getTarget());
					break;
					// artillery
					case 1:
						manArty.spawnProjectile("standard", getSpawnLocation("artillery"), getTarget());
					break;
					// fast
					case 2:
						manMiss.spawnProjectile("fast", getSpawnLocation("fast"), getTarget(), 0, P_FAST);
					break;
					// big
					case 3:
						manMiss.spawnProjectile("big", getSpawnLocation("big"), getTarget(), 0, P_BIG);
					break;
					// cluster
					case 4:
						manMiss.spawnProjectile("cluster", getSpawnLocation("cluster"), getTarget());
					break;
					// LASM
					case 5:
						manMiss.spawnProjectile("LASM", getSpawnLocation("LASM"), getTarget());
					break;
					case 6:
						manMiss.spawnProjectile("bomber", getSpawnLocation("bomber"), getTarget());
					break;
					default:
						trace("WARN! Didn't spawn anything...");
				}								  
							  
				
				spawnDelay = spawnMin;
				enemiesRemaining--;
				//cg.game.mc_gui.mc_statusCenter.tf_status.text = enemiesRemaining + " projectile(s) left."
	
				// advance time from day to sunset
				if (dayFlag == 0 && enemiesRemaining == 5)
				{
					dayFlag++;
					advanceTime("day");
				}
				// advance time from sunset to night
				else if (dayFlag == 1 && enemiesRemaining <= 2)
				{
					if (cg.game.bg.ocean.currentFrame < 152)		// magic number :c
						return;
					dayFlag++;
					advanceTime("sunset");
				}

			}
	
			if (spawnDelay < spawnMax)		// ???
				spawnDelay = spawnMin;
		}
		
		/**	Determines random spawn location based on rules for a given projectile type
		 * 
		 * @param	type	name of projectile to spawn (ex "missile")
		 * @return			restricted randomly-generated spawn point
		 */
		private function getSpawnLocation(type:String):Point
		{
			var regions:Array = spawnLoc[type];
			if (!regions) return null;
			
			var region:Array = regions[int(getRand(0, regions.length - 1))];
			return new Point(getRand(region[0].x, region[1].x), getRand(region[0].y, region[1].y));
		}
		
		private function getTarget():Point
		{
			return new Point(targetX + -2 * targetVarianceX + getRand(0, targetVarianceX),
							 targetY + -2 * targetVarianceY + getRand(0, targetVarianceY));
		}
		
		// picks 1 index given an array of choices with elements as weights
		private function choose(choiceWeights:Array):int
		{
			var sum:int = 0;
			var i:int;
			for (i = 0; i < choiceWeights.length; i++)
				sum += choiceWeights[i];
				
			var rand:int = getRand(0, sum-1);
			for (i = 0; i < choiceWeights.length; i++)
			{
				if (rand < choiceWeights[i])
					return i;
				rand -= choiceWeights[i];
			}
			
			trace("WARN! choose() returning -1...");
			return -1;
		}
		
		private function resetSpawnType():void
		{
			spawnType = [0, 0, 0, 0, 0, 0, 0, 0, 0];
		}
	}
}