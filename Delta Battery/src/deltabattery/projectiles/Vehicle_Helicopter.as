package deltabattery.projectiles 
{
	import cobaltric.ContainerGame;
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	/**
	 * Helicopter which flies to the center of the stage and fires bullets.
	 * Bullets can destroy player missiles.
	 * 
	 * @author Gavin Figueroa
	 */
	public class Vehicle_Helicopter extends ABST_Vehicle 
	{
		private var timer:Number = 0;
		
		public function Vehicle_Helicopter(_cg:ContainerGame, _mc:MovieClip, _origin:Point, _target:Point, _type:int = 0, params:Object = null)
		{
			_target.y = _origin.y;
			
			if (!params)
				params = { velocity:(2 + Math.random()) };
			else
				params["velocity"] = 2 + Math.random();
			
			super(_cg, _mc, _origin, _target, _type, params);
			
			hp = hpMax = 8;
		}
		
		override public function step():Boolean
		{
			if (!markedForDestroy)
			{
				// calculate and perform movement
				velocity = (target.x - mc.x) / 75;
				
				if (mc.x < target.x)
					mc.x += velocity;

				if (mc.x > -150 && timer % 150 == 0)
					cg.manBull.spawnProjectile("chain", new Point(mc.x, mc.y), new Point(cg.game.city.x, cg.game.city.y));
			}
			
			timer++;
			
			// returns TRUE if this object needs to be removed
			return readyToDestroy;
		}
	}

}