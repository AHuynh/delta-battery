package deltabattery.projectiles 
{
	import cobaltric.ContainerGame;
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Alexander Huynh
	 */
	public class Bullet_Flak extends ABST_Bullet 
	{
		
		public function Bullet_Flak(_cg:ContainerGame, _mc:MovieClip, _origin:Point, _target:Point, _type:int=0, _life:int=15, stats:Object=null) 
		{
			dist = getDistance(_origin.x, _origin.y, _target.x, _target.y);
			
			var accScale:Number;
			if (dist < 100)
				accScale = 1;
			else if (dist > 500)
				accScale = 5;
			else
				accScale = .01 * dist;

			_target.x += getRand( -20, 20) * accScale;
			_target.y += getRand( -20, 20) * accScale;
			
			super(_cg, _mc, _origin, _target, _type, _life, stats);
			
			mc.gotoAndStop("tracer");
			mc.alpha = .4;
			
			explosionScale = .5;
		}
		
		override public function step():Boolean
		{
			if (!markedForDestroy)
			{
				mc.x += velocity * Math.cos(rot);
				mc.y += velocity * Math.sin(rot);
				life--;

				dist = getDistance(mc.x, mc.y, target.x, target.y);

				if (life <= 0 || (Math.abs(mc.x) > 500 || dist < 5 || dist > prevDist || mc.y > 170))
				{
					cg.manExpl.spawnExplosion(new Point(mc.x, mc.y), type, explosionScale);
					destroy();
				}
				else
					prevDist = dist;
			}
			
			return readyToDestroy;
		}
		
	}

}