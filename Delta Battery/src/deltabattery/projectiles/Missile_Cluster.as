package deltabattery.projectiles 
{
	import cobaltric.ContainerGame;
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Alexander Huynh
	 */
	public class Missile_Cluster extends ABST_Missile 
	{
		private var airburst:int;				// time to burst
		
		public function Missile_Cluster(_cg:ContainerGame, _mc:MovieClip, _origin:Point, _target:Point, _type:int=0, params:Object=null) 
		{
			
			if (!params)
			{
				params = new Object();
				params["velocity"] = 2;
				params["partInterval"] = 10;
			}
			
			super(_cg, _mc, _origin, _target, _type, params);
			airburst = 150 + getRand(0, 90);
		}	
		
		override public function step():Boolean
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

				// overridden code
				if (--airburst == 0)
				{
					// spawn rockets
					createExplosion = false;
					cg.manMiss.spawnProjectile("rocket", new Point(mc.x, mc.y), new Point(target.x, target.y), type);
					cg.manMiss.spawnProjectile("rocket", new Point(mc.x, mc.y), new Point(target.x + 30, target.y - 30), type);
					cg.manMiss.spawnProjectile("rocket", new Point(mc.x, mc.y), new Point(target.x - 30, target.y + 30), type);
					destroy();
				}
			}
			
			return readyToDestroy;
		}
	}
}