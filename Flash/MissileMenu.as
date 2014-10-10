package 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.events.Event;
	
	public class MissileMenu extends MovieClip
	{
		private var velocity:Number;
		private var rot:Number;
		
		private var partCounter:int = 5;
		
		private var markedForDestroy:Boolean;
		private var readyToDestroy:Boolean;
		
		private var par:MovieClip;
		private var timerKill:Timer;
		
		public function MissileMenu()
		{
			velocity = Math.random() * 3 + 5;
			rotation = (Math.random() * 35) + 20;
			rot = rotation * Math.PI / 180;
			
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			par = MovieClip(parent.parent);
		}
		
		public function step():Boolean
		{
			if (!readyToDestroy)
			{
				x += velocity * Math.cos(rot);
				y += velocity * Math.sin(rot);
				
				if (--partCounter == 0)
				{
					partCounter = 5;
					if (par)
						par.spawnParticle(this);
				}
				
				if (!markedForDestroy && x > 400)
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
			if (timerKill && timerKill.hasEventListener(TimerEvent.TIMER))
				timerKill.removeEventListener(TimerEvent.TIMER, cleanup);
			timerKill = null;
			
			readyToDestroy = true;
		}
	}
}
