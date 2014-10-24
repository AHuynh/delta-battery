package deltabattery.projectiles 
{
	import cobaltric.ContainerGame;
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Alexander Huynh
	 */
	public class Missile_LASM extends ABST_Missile 
	{
		private var fall:Boolean = false;		// TRUE if heading down, FALSE if travelling horizontally
		
		public function Missile_LASM(_cg:ContainerGame, _mc:MovieClip, _origin:Point, _target:Point, _type:int=0, params:Object=null) 
		{
			_target.y = _origin.y;
			
			super(_cg, _mc, _origin, _target, _type, params);
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

				dist = getDistance(mc.x, mc.y, target.x, target.y);

				if ((Math.abs(mc.x) > 800 || dist < 5 || dist > prevDist || mc.y > 370))
				{
					if (mc.y > 410)
					{
						destroy();
						return readyToDestroy;
					}
					if (!fall)
					{
						fall = true;
						mc.rotation = 90;
						velocity += 2;
						rot = degreesToRadians(mc.rotation);
					}
				}
				else
					prevDist = dist;
			}
			
			// returns TRUE if this object needs to be removed
			return readyToDestroy;
		}
	}
}