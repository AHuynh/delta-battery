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
	 * ...
	 * @author Alexander Huynh
	 */
	public class ABST_Missile extends ABST_Base 
	{
		public var cg:ContainerGame;
		public var mc:MovieClip;
		
		public var type:int;
		
		private var origin:Point;
		private var target:Point;

		private var velocity:Number;
		private var rot:Number;
		
		private var renderer:DisplayObjectRenderer;
		private var emitter:Emitter2D;
		
		private var markedForDestroy:Boolean;
		private var readyToDestroy:Boolean;
		
		private var timerKill:Timer;
		private var tgt:MissileTarget;
		
		public function ABST_Missile(_cg:ContainerGame, _mc:MovieClip, _dor:DisplayObjectRenderer, _origin:Point, _target:Point, _type:int = 0, params:Object = null) 
		{
			cg = _cg;
			mc = _mc;		
			renderer = _dor;
			origin = _origin;
			target = _target;
			
			type = _type;
			
			mc.x = origin.x;
			mc.y = origin.y;
			
			tgt = new MissileTarget();
			tgt.x = target.x;
			tgt.y = target.y;
			cg.game.c_main.addChild(tgt);

			velocity = Math.random() * 2 + 4;
			mc.rotation = getAngle(_origin.x, _origin.y, target.x, target.y);
			rot = degreesToRadians(mc.rotation);
					
			emitter = new Emitter2D();
			emitter.counter = new Steady(12);
			emitter.addInitializer(new ImageClass(ParticleSmokeTrail));
			emitter.addInitializer(new Position(new DiscZone(new Point(mc.x, mc.y), 5, 3)));
			emitter.addInitializer(new Velocity(new PointZone(new Point(velocity * Math.cos(rot), velocity * Math.sin(rot) + 10))));
			
			emitter.addAction(new Move());
			emitter.addInitializer(new Lifetime(3, 4));
			emitter.addAction(new Age());
			emitter.addAction(new ColorChange(0xFFFFFFFF, 0x00FFFFFF));
			
			emitter.start();

			renderer.addEmitter(emitter);
			
			if (params)
			{
				if (params["velocity"])
					velocity = params["velocity"];
			}
		}
		
		public function step(manExpl:ManagerExplosion):Boolean
		{
			if (!readyToDestroy && !markedForDestroy)
			{
				mc.x += velocity * Math.cos(rot);
				mc.y += velocity * Math.sin(rot);
				
				emitter.x = mc.x - 22 * Math.cos(rot);
				emitter.y = mc.y + 50;
				
				var dist:Number = 99999;
				var distToExplosion:Number = 99999;
				var expl:ABST_Explosion;
				
				for (var i:int = manExpl.objArr.length - 1; i >= 0; i--)
				{
					if (type == manExpl.objArr[i].type) continue;
					
					dist = getDistance(mc.x, mc.y, manExpl.objArr[i].mc.x, manExpl.objArr[i].mc.y);
					if (dist < distToExplosion)
						distToExplosion = dist;
				}
				
				// TODO replace magic numbers
				if ((Math.abs(mc.x) > 500 || distToExplosion < 25 || getDistance(mc.x, mc.y, target.x, target.y) < 15))		// TODO check if moving away from target, if so explode
					destroy();
			}
			
			return readyToDestroy;
		}
		
		public function destroy():void
		{
			markedForDestroy = true;
			
			mc.visible = false;

			timerKill = new Timer(4000);
			timerKill.addEventListener(TimerEvent.TIMER, cleanup);
			timerKill.start();
			
			emitter.counter = new Steady();
			
			cg.manExpl.spawnExplosion(new Point(mc.x, mc.y), type);
			cg.game.c_main.removeChild(tgt);
			tgt.visible = false;
			tgt = null;
		}
		
		public function cleanup(e:TimerEvent):void
		{
			timerKill.removeEventListener(TimerEvent.TIMER, cleanup);
			timerKill = null;

			emitter.stop();
			renderer.removeEmitter(emitter);
			emitter = null;
			
			readyToDestroy = true;
		}
	}
}