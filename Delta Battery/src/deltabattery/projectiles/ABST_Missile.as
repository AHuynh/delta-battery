package deltabattery.projectiles
{
	import cobaltric.ContainerGame;
	import deltabattery.ABST_Base;
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	/**	A generic, gravity-ignoring projectile
	 * 
	 * 	@author Alexander Huynh
	 */
	public class ABST_Missile extends ABST_Base 
	{
		public var cg:ContainerGame;					// reference to ContainerGame
		public var mc:MovieClip;						// the MovieClip corresponding to this missile
		
		public var type:int;							// affilation, 0 - enemy, 1 - player
		public var damage:Number;						// damage to deal to the city
		
		public var origin:Point;						// spawn location
		protected var target:Point;						// target coordinates
		protected var targetMC:MovieClip;				// target MovieClip (default city)
		
		protected var partEnabled:Boolean = true;		// if TRUE, spawn particles while in flight
		protected var partCount:int = 5;				// particle timer
		protected var partInterval:int = partCount;		// frames inbetween particle spawn
		protected var partType:String = "";				// type of particle
		
		protected var dist:Number;						// distance to the target
		protected var prevDist:Number;					// distance to the target 1 frame before

		public var velocity:Number;
		public var rot:Number;
		
		protected var createExplosion:Boolean;			// if TRUE, spawn an explosion upon destruction
		public var markedForDestroy:Boolean;			// helper for destroy
		public var readyToDestroy:Boolean;				// helper for destroy
		
		protected var timerKill:Timer;					// helper for destroy
		protected var tgt:MissileTarget;				// + indicator on player-made projectiles
		
		protected var awardMoney:Boolean = true;
		
		public function ABST_Missile(_cg:ContainerGame, _mc:MovieClip, _origin:Point,
								     _target:Point, _type:int = 0, params:Object = null)
		{
			cg = _cg;
			mc = _mc;		
			origin = _origin;
			target = _target;
			
			type = _type;
			
			mc.x = origin.x;
			mc.y = origin.y;
			
			targetMC = cg.game.city;
			
			// default values
			var useTarget:Boolean = false;
			damage = 9 + getRand(0, 2);
			velocity = Math.random() * 2 + 4;
			createExplosion = true;
			
			if (params)
			{
				if (params["target"] != null)
					useTarget = params["target"];
				if (params["velocity"] != null)
					velocity = params["velocity"];
				if (params["partInterval"] != null)
					partInterval = params["partInterval"];
				if (params["explode"] != null)
					createExplosion = params["explode"];
			}
			
			if (useTarget)
			{
				tgt = new MissileTarget();
				tgt.x = target.x;
				tgt.y = target.y;
				cg.game.c_main.addChild(tgt);
			}

			mc.rotation = getAngle(origin.x, origin.y, target.x, target.y);
			rot = degreesToRadians(mc.rotation);
			
			dist = prevDist = getDistance(origin.x, origin.y, target.x, target.y);
		}
		
		public function step():Boolean
		{
			if (!markedForDestroy)
			{
				// calculate and perform movement
				var dx:Number = velocity * Math.cos(rot);
				var dy:Number = velocity * Math.sin(rot);
				
				mc.x += dx;
				mc.y += dy;
				
				updateParticle(dx, dy);
				checkTarget();

				dist = getDistance(mc.x, mc.y, target.x, target.y);
				
				// TODO replace magic numbers
				// destroy if within range of target
				if ((Math.abs(mc.x) > 800 || dist < 5 || dist > prevDist || mc.y > 370))
					destroy();
				else
					prevDist = dist;
			}
			
			// returns TRUE if this object needs to be removed
			return readyToDestroy;
		}
		
		// spawns a particle if necessary
		protected function updateParticle(dx:Number, dy:Number):void
		{
			if (partEnabled && --partCount == 0)
			{
				partCount = partInterval;
				cg.manPart.spawnParticle(partType, new Point(mc.x, mc.y), 0, dx * .1, dy * .10, .05);
			}
		}
		
		// if this projectile is close to the city, with a 20% chance of happening per frame,
		// destroy this projectile and damage the city
		// dest = TRUE always except when called in destroy(), below
		protected function checkTarget(dest:Boolean = true):void
		{
			if (type == 1) return;				// ignore player projectiles
			if (abs(mc.x - targetMC.x) < 100 && abs(mc.y - targetMC.y + 50) < 50 && Math.random() > .8)
			{
				cg.damageCity(this);
				if (dest)
				{
					awardMoney = false;
					destroy();
				}
			}
		}

		// kill this projectile, spawning an explosion if spawnExplosion is TRUE
		public function destroy():void
		{
			if (markedForDestroy) return;		// already going to be destroyed, quit
			checkTarget(false);
			
			// TODO calculate money
			if (awardMoney && type == 0)
				cg.addMoney(100 + 50 * (velocity / 6));
			
			markedForDestroy = true;
			mc.visible = false;
 
			timerKill = new Timer(2000);
			timerKill.addEventListener(TimerEvent.TIMER, cleanup);
			timerKill.start();
			
			if (createExplosion)
				cg.manExpl.spawnExplosion(new Point(mc.x, mc.y), type);

			if (tgt)
			{
				cg.game.c_main.removeChild(tgt);
				tgt.visible = false;
				tgt = null;
			}
		}
		
		public function cleanup(e:TimerEvent):void
		{
			if (timerKill)
			{
				timerKill.removeEventListener(TimerEvent.TIMER, cleanup);
				timerKill = null;
			}			
			readyToDestroy = true;
		}
	}
}