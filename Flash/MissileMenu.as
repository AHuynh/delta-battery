package 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import org.flintparticles.twoD.emitters.Emitter2D;
	import org.flintparticles.twoD.renderers.DisplayObjectRenderer;
	import org.flintparticles.common.counters.Steady;
	import org.flintparticles.common.initializers.ImageClass;
	import org.flintparticles.twoD.initializers.Position;
	import org.flintparticles.twoD.initializers.Velocity;
	import org.flintparticles.twoD.actions.Move;
	import org.flintparticles.twoD.zones.PointZone;
	import org.flintparticles.twoD.zones.DiscZone;
	import org.flintparticles.common.initializers.Lifetime;
	import org.flintparticles.common.actions.Age;
	import org.flintparticles.common.actions.ColorChange;
	
	public class MissileMenu extends MovieClip
	{
		private var velocity:Number;
		private var rot:Number;
		
		private var renderer:DisplayObjectRenderer;
		private var emitter:Emitter2D;
		
		private var markedForDestroy:Boolean;
		private var readyToDestroy:Boolean;
		
		private var timerKill:Timer;
		
		public function MissileMenu(dor:DisplayObjectRenderer)
		{
			velocity = Math.random() * 3 + 5;
			rotation = (Math.random() * 25) + 145;
			rot = rotation * Math.PI / 180;
			
			renderer = dor;
			
			emitter = new Emitter2D();
			emitter.counter = new Steady(20);
			emitter.addInitializer(new ImageClass(ParticleSmokeTrail));
			emitter.addInitializer(new Position(new DiscZone(new Point(x, y), 5, 3)));
			emitter.addInitializer(new Velocity(new PointZone(new Point(velocity * Math.cos(rot), velocity * Math.sin(rot) + 10))));
			
			emitter.addAction(new Move());
			emitter.addInitializer(new Lifetime(3, 4));
			emitter.addAction(new Age());
			emitter.addAction(new ColorChange(0xFFFFFFFF, 0x00FFFFFF));
			
			emitter.start();
			
			renderer.addEmitter(emitter);
		}
		
		public function step():Boolean
		{
			if (!readyToDestroy)
			{
				x += velocity * Math.cos(rot);
				y += velocity * Math.sin(rot);
				
				emitter.x = x - 22 * Math.cos(rot);
				emitter.y = y - 5;
				
				if (!markedForDestroy && x < -400)
					destroy();
			}
			
			return readyToDestroy;
		}
		
		public function destroy():void
		{
			markedForDestroy = true;

			timerKill = new Timer(4000);
			timerKill.addEventListener(TimerEvent.TIMER, cleanup);
			timerKill.start();
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
