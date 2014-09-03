package deltabattery 
{
	import cobaltric.ContainerGame;
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	import org.flintparticles.common.actions.Age;
	import org.flintparticles.common.actions.ColorChange;
	import org.flintparticles.common.counters.Steady;
	import org.flintparticles.common.initializers.ImageClass;
	import org.flintparticles.common.initializers.Lifetime;
	import org.flintparticles.twoD.actions.Move;
	import org.flintparticles.twoD.emitters.Emitter2D;
	import org.flintparticles.twoD.initializers.Position;
	import org.flintparticles.twoD.initializers.Velocity;
	import org.flintparticles.twoD.renderers.DisplayObjectRenderer;
	import org.flintparticles.twoD.zones.DiscZone;
	import org.flintparticles.twoD.zones.PointZone;
	
	/**
	 * A generic, gravity-ignoring projectile
	 * @author Alexander Huynh
	 */
	public class ABST_Missile extends ABST_Base 
	{
		public var cg:ContainerGame;
		public var mc:MovieClip;
		
		public var type:int;
		
		protected var origin:Point;
		protected var target:Point;
		
		protected var dist:Number;
		protected var prevDist:Number;

		protected var velocity:Number;
		protected var rot:Number;
		
		protected var renderer:DisplayObjectRenderer;
		protected var emitter:Emitter2D;
		
		protected var createExplosion:Boolean;
		protected var markedForDestroy:Boolean;
		protected var readyToDestroy:Boolean;
		
		protected var timerKill:Timer;
		protected var tgt:MissileTarget;
		
		public function ABST_Missile(_cg:ContainerGame, _mc:MovieClip, _dor:DisplayObjectRenderer,
									 _origin:Point, _target:Point, _type:int = 0, params:Object = null) 
		{
			cg = _cg;
			mc = _mc;		
			renderer = _dor;
			origin = _origin;
			target = _target;
			
			type = _type;
			
			mc.x = origin.x;
			mc.y = origin.y;
			
			// default values
			var useTarget:Boolean = true;
			velocity = Math.random() * 2 + 4;
			var useEmitter:Boolean = true;
			var emitterRate:int = 12;
			var minLife:Number = 3;
			var maxLife:Number = 4;
			createExplosion = true;
			
			if (params)
			{
				if (params["target"] != null)
					useTarget = params["target"];
				if (params["velocity"] != null)
					velocity = params["velocity"];
				if (params["useEmitter"] != null)
					useEmitter = params["useEmitter"];
				if (params["emitterRate"] != null)
					emitterRate = params["emitterRate"];
				if (params["minLife"] != null)
					emitterRate = params["minLife"];
				if (params["maxLife"] != null)
					emitterRate = params["maxLife"];
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

			if (useEmitter)
			{
				emitter = new Emitter2D();
				emitter.counter = new Steady(emitterRate);
				emitter.addInitializer(new ImageClass(ParticleSmokeTrail));
				emitter.addInitializer(new Position(new DiscZone(new Point(mc.x, mc.y), 5, 3)));
				emitter.addInitializer(new Velocity(new PointZone(new Point(velocity * Math.cos(rot), velocity * Math.sin(rot) + 10))));
				
				emitter.addAction(new Move());
				emitter.addInitializer(new Lifetime(minLife, maxLife));
				emitter.addAction(new Age());
				emitter.addAction(new ColorChange(0xFFFFFFFF, 0x00FFFFFF));
				
				emitter.start();

				renderer.addEmitter(emitter);
			}
		}
		
		public function step():Boolean
		{
			if (!markedForDestroy)
			{
				mc.x += velocity * Math.cos(rot);
				mc.y += velocity * Math.sin(rot);
				
				if (emitter)
				{
					emitter.x = mc.x - 22 * Math.cos(rot);
					emitter.y = mc.y + 50;
				}
				
				dist = getDistance(mc.x, mc.y, target.x, target.y);
				
				// TODO replace magic numbers
				if ((Math.abs(mc.x) > 800 || dist < 5 || dist > prevDist))
					destroy();
				else
					prevDist = dist;
			}
			
			return readyToDestroy;
		}
		
		public function destroy():void
		{
			if (markedForDestroy) return;
			
			markedForDestroy = true;
			
			mc.visible = false;
 
			timerKill = new Timer(4000);
			timerKill.addEventListener(TimerEvent.TIMER, cleanup);
			timerKill.start();
			
			if (emitter)
				emitter.counter = new Steady();
			
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

			if (emitter)
			{
				emitter.stop();
				renderer.removeEmitter(emitter);
				emitter = null;
			}
			
			readyToDestroy = true;
		}
	}
}