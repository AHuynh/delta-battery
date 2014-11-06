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
		/*	spawnLoc[type] -> [null, [(x1, y1), (x2, y2)], null]
		 * 
		 * 	let arr be spawnLoc[type]
		 * 	arr				null if not able to spawn in this wave
		 * 	arr[]			regions to spawn in
		 * 	arr[][0..1]		upper left and lower right corners of
		 * 					spawn region
		 */
		
		private var spawnType:Array;
		/*	chance (weights) of given projectile to spawn
		 */
		private const MISSILE:int 	= 0;
		private const ARTY:int 		= 1;
		private const FAST:int 		= 2;
		private const BIG:int 		= 3;
		private const CLUSTER:int 	= 4;
		private const LASM:int 		= 5;
		private const BOMBER:int 	= 6;
		private const HELI:int 		= 7;
		private const PLANE:int 	= 8;
		private const SHIP:int 		= 9;
		private const SAT:int		= 10;
		private const POPUP:int		= 11;
		
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
		private const R_LEFT_CENTER:Array = [new Point( -500, -75), new Point( -450, 75)];
		private const R_RIGHT_LASM:Array = [new Point( 450, -250), new Point( 410, -150)];
		private const R_RIGHT_BOT:Array = [new Point( 150, 160), new Point( 150, 170)];
		
		private const R_SEA:Array = [new Point( -360, 120), new Point( -200, 130)];
		
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
					enemiesRemaining = 0;

					// enable missiles - (corner)
					spawnLoc[MISSILE] = [R_LEFT_TOP];
					spawnLoc[ARTY] = [R_ARTY_NORM];
					spawnLoc[FAST] = [R_LEFT_TOP];
					spawnLoc[BIG] = [R_LEFT_TOP];
					spawnLoc[CLUSTER] = [R_LEFT_TOP];
					spawnLoc[LASM] = [R_LEFT_LASM];
					spawnLoc[BOMBER] = [R_LEFT_LASM];
					spawnLoc[HELI] = [R_LEFT_CENTER];
					spawnLoc[PLANE] = [R_RIGHT_LASM];
					spawnLoc[SHIP] = [R_RIGHT_BOT];
					spawnLoc[SAT] = [R_LEFT_TOP];
					spawnLoc[POPUP] = [R_SEA];

					// set spawn probabilities
					spawnType[MISSILE] = 5;
					spawnType[ARTY] = 4;
					spawnType[FAST] = 4;
					spawnType[BIG] = 4;
					spawnType[CLUSTER] = 3;
					spawnType[LASM] = 3;
					spawnType[BOMBER] = 2;
					spawnType[HELI] = 2;
					spawnType[PLANE] = 1;
					spawnType[SHIP] = 1;
					spawnType[SAT] = 1;
					spawnType[POPUP] = 2;
					
					spawnDelay = 30 * 2;		// 2 seconds initial delay
					spawnMin = 15;// 30 * 2;			// 2 seconds minimum
					spawnMax = -30 * 1.5;// 4;			// 4 seconds maximum
					spawnRandom = .98;
				break;
				// faster standard missile
				case 2:
					enemiesRemaining = 12;
					
					// set spawn probabilities
					spawnType[MISSILE] = 1;			// 100% missile
					
					spawnDelay = 30 * 2;
					spawnMin = 20;
					spawnMax = 25 * -1;
					spawnRandom = .98;
				break;
				// artillery
				case 3:
					enemiesRemaining = 10;
					
					// enable projectiles
					spawnLoc[ARTY] = [R_ARTY_NORM];
					
					// set spawn probabilities
					spawnType[ARTY] = 1;			// 100% artillery
					
					spawnDelay = 30 * 2;
					spawnMin = 30 * 2 + 15;		// 2.5 seconds minimum
					spawnMax = -30 * 4;
					spawnRandom = .97;
				break;
				// missiles + artillery
				case 4:
					enemiesRemaining = 5;
					
					// enable projectiles
					//spawnLoc[MISSILE] = [R_LEFT_TOP];
					//spawnLoc[ARTY] = [R_ARTY_NORM];
					spawnLoc[CLUSTER] = [R_LEFT_TOP];
					
					// set spawn probabilities
					//spawnType[MISSILE] = 3;			// 75% missile
					//spawnType[ARTY] = 1;			// 25% artillery
					spawnType[CLUSTER] = 1;			// 100% cluster
					
					spawnDelay = 30 * 2;
					spawnMin = 30 * 2;			// 2 seconds minimum
					spawnMax = -30 * 3;			// 3 seconds maximum
					spawnRandom = .96;
				break;
				case 5:			// test
					enemiesRemaining = 6;
					
					// enable projectiles
					spawnLoc[HELI] = [R_LEFT_CENTER];
					
					// set spawn probabilities
					spawnType[HELI] = 1;			// 100% cluster
					
					spawnDelay = 0;
					spawnMin = 30 * 2;			// 2 seconds minimum
					spawnMax = -30 * 3;			// 3 seconds maximum
					spawnRandom = .96;
				break;
				case 6:			// test
				case 7:
					enemiesRemaining = 14;
					
					// enable projectiles
					spawnLoc[BOMBER] = [R_LEFT_LASM];
					spawnLoc[PLANE] = [R_RIGHT_LASM];
					spawnLoc[SHIP] = [R_RIGHT_BOT];
					
					// set spawn probabilities
					spawnType[BOMBER] = 3;
					spawnType[PLANE] = 1;		
					spawnType[SHIP] = 1;		
					
					spawnDelay = 0;
					spawnMin = 30 * 2;			// 2 seconds minimum
					spawnMax = -30 * 3;			// 3 seconds maximum
					spawnRandom = .96;
				break;
				
				case 9:			// test
					enemiesRemaining = 4;
					
					// enable projectiles
					spawnLoc[CLUSTER] = [R_LEFT_TOP];
					
					// set spawn probabilities
					spawnType[CLUSTER] = 1;			// 100% cluster
					
					spawnDelay = 0;
					spawnMin = 30 * 2;			// 2 seconds minimum
					spawnMax = -30 * 3;			// 3 seconds maximum
					spawnRandom = .96;
				break;
				case 8:			// test
					enemiesRemaining = 4;
					
					// enable projectiles
					spawnLoc[FAST] = [R_LEFT_TOP];
					
					// set spawn probabilities
					spawnType[FAST] = 1;			// 100% fast
					
					spawnDelay = 0;
					spawnMin = 30 * 2;			// 2 seconds minimum
					spawnMax = -30 * 3;			// 3 seconds maximum
					spawnRandom = .96;
				break;
				case 15:			// test
					enemiesRemaining = 16;
					
					// enable projectiles
					spawnLoc[HELI] = [R_LEFT_CENTER];
					spawnLoc[BOMBER] = [R_LEFT_LASM];
					spawnLoc[PLANE] = [R_RIGHT_LASM];
					
					// set spawn probabilities
					spawnType[HELI] = 1;	
					spawnType[BOMBER] = 1;
					spawnType[PLANE] = 1;		
					
					spawnDelay = 0;
					spawnMin = 30 * 2;			// 2 seconds minimum
					spawnMax = -30 * 3;			// 3 seconds maximum
					spawnRandom = .96;
				break;
				case 10:			// test
					enemiesRemaining = 4;
					
					// enable projectiles
					spawnLoc[LASM] = [R_LEFT_LASM];
					
					// set spawn probabilities
					spawnType[LASM] = 1;			// 100% LASM
					
					spawnDelay = 0;
					spawnMin = 30 * 2;			// 2 seconds minimum
					spawnMax = -30 * 3;			// 3 seconds maximum
					spawnRandom = .96;
				break;
				
				default:		// crazy demo
					enemiesRemaining = 80;
					
					// enable projectiles
					spawnLoc[MISSILE] = [R_LEFT_TOP];
					spawnLoc[ARTY] = [R_ARTY_NORM];
					
					// set spawn probabilities
					spawnType[MISSILE] = 1;			// 50% missile
					spawnType[ARTY] = 1;			// 50% artillery
					
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
					case MISSILE:
						manMiss.spawnProjectile("standard", getSpawnLocation(MISSILE), getTarget());
					break;
					case ARTY:
						manArty.spawnProjectile("artillery", getSpawnLocation(ARTY), getTarget());
					break;
					case FAST:
						manMiss.spawnProjectile("fast", getSpawnLocation(FAST), getTarget(), 0, P_FAST);
					break;
					case BIG:
						manMiss.spawnProjectile("big", getSpawnLocation(BIG), getTarget(), 0, P_BIG);
					break;
					case CLUSTER:
						manMiss.spawnProjectile("cluster", getSpawnLocation(CLUSTER), getTarget());
					break;
					case LASM:
						manMiss.spawnProjectile("LASM", getSpawnLocation(LASM), getTarget());
					break;
					case POPUP:
						manMiss.spawnProjectile("pop", getSpawnLocation(POPUP), getTarget());
					break;
					case BOMBER:
						manMiss.spawnProjectile("bomber", getSpawnLocation(BOMBER), getTarget());
					break;
					case SAT:
						manMiss.spawnProjectile("satellite", getSpawnLocation(SAT), getTarget());
					break;
					case HELI:
						manMiss.spawnProjectile("helicopter", getSpawnLocation(HELI), new Point(getRand(-75, 75), getRand(-50, 50)));
					break;
					case PLANE:
						manMiss.spawnProjectile("plane", getSpawnLocation(PLANE), new Point(-500, 0));
					break;
					case SHIP:
						manMiss.spawnProjectile("ship", getSpawnLocation(SHIP), new Point(300, 0));
					break;
					default:
						trace("WARN! Didn't spawn anything...");
				}								  
				
				spawnDelay = spawnMin;
				enemiesRemaining--;
	
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
					cg.game.bg.cacheAsBitmap = false;
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
		private function getSpawnLocation(type:int):Point
		{
			var regions:Array = spawnLoc[type];
			if (!regions) return null;
			
			var region:Array = regions[int(getRand(0, regions.length - 1))];
			return new Point(getRand(region[0].x, region[1].x), getRand(region[0].y, region[1].y));
		}
		
		private function getTarget():Point
		{
			return new Point(targetX + getRand(-targetVarianceX, targetVarianceX),
							 targetY + getRand(-targetVarianceY, targetVarianceY));
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
			if (spawnType)
			{
				for (var i:int = 0; i < spawnType.length; i++)
					spawnType[i] = 0;
			}
			else
				spawnType = [];
		}
	}
}