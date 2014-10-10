package deltabattery.projectiles
{
	import cobaltric.ContainerGame;
	import deltabattery.ABST_Base;
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	/**
	 * A generic, gravity-ignoring projectile
	 * @author Alexander Huynh
	 */
	public class ABST_Missile extends ABST_Base 
	{
		public var cg:ContainerGame;
		public var mc:MovieClip;
		
		public var type:int;
		public var damage:Number;
		
		public var origin:Point;
		protected var target:Point;
		protected var targetMC:MovieClip;
		
		protected var partEnabled:Boolean = true;
		protected var partCount:int = 5;				// particle timer
		protected var partInterval:int = partCount;		// frames inbetween particle spawn
		protected var partType:String = "";				// type of particle
		
		protected var dist:Number;
		protected var prevDist:Number;

		public var velocity:Number;
		public var rot:Number;
		
		protected var createExplosion:Boolean;
		protected var markedForDestroy:Boolean;
		public var readyToDestroy:Boolean;
		
		protected var timerKill:Timer;
		protected var tgt:MissileTarget;
		
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
			var useTarget:Boolean = true;
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
				var dx:Number = velocity * Math.cos(rot);
				var dy:Number = velocity * Math.sin(rot);
				
				mc.x += dx;
				mc.y += dy;

				updateParticle(dx, dy);
				checkTarget();
			
				dist = getDistance(mc.x, mc.y, target.x, target.y);
				
				// TODO replace magic numbers
				if ((Math.abs(mc.x) > 800 || dist < 5 || dist > prevDist || mc.y > 370))
					destroy();
				else
					prevDist = dist;
			}
			
			return readyToDestroy;
		}
		
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
		protected function checkTarget(dest:Boolean = true):void
		{
			if (type == 1) return;				// ignore player projectiles
			if (abs(mc.x - targetMC.x) < 100 && abs(mc.y - targetMC.y) < 50 && Math.random() > .8)
			{
				cg.damageCity(this);
				if (dest)
					destroy();
			}
		}
		
		public function destroy():void
		{
			if (markedForDestroy) return;
			checkTarget(false);
			
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
			
			// TEMPORARY
			if (type == 0)
				cg.addMoney(100 + 50 * (velocity / 6));
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