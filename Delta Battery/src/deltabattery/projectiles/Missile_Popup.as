package deltabattery.projectiles 
{
	import cobaltric.ContainerGame;
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Alexander Huynh
	 */
	public class Missile_Popup extends ABST_Missile 
	{
		private var dx:Number;
		private var dy:Number;
		private const g:Number = 0.06;

		private var popup:Boolean = true;		// TRUE pre-ignite
		
		public function Missile_Popup(_cg:ContainerGame, _mc:MovieClip, _origin:Point, _target:Point, _type:int=0, params:Object=null) 
		{
			super(_cg, _mc, _origin, _target, _type, params);
			
			dy = -5 + getRand(0, 1.5);
			dx = 0;
		}
		
		override public function step():Boolean
		{
			if (!markedForDestroy)
			{
				mc.x += dx;
				mc.y += dy;
				
				if (popup)
				{
					if (dy > 0)
					{
						popup = false;
						velocity *= 1.4;
						dx = velocity * Math.cos(rot);
						dy = velocity * Math.sin(rot);
					}
					else
					{
						mc.rotation = getAngle(mc.x, mc.y, target.x, target.y);
						rot = degreesToRadians(mc.rotation);
						dy += g;
					}
				}
				else
				{
					updateParticle(dx, dy);
					checkTarget();
					dist = getDistance(mc.x, mc.y, target.x, target.y);
				}
				
				if (Math.abs(mc.x) > 800 || (!popup && (dist < 5 || mc.y > 170)))
					destroy();
			}
			
			// returns TRUE if this object needs to be removed
			return readyToDestroy;
		}
	}

}