package deltabattery.projectiles 
{
	import cobaltric.ContainerGame;
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Alexander Huynh
	 */
	public class ABST_Artillery extends ABST_Missile 
	{
		protected var gravity:Number = .02;
		protected var dx:Number;
		protected var dy:Number;
		
		public function ABST_Artillery(_cg:ContainerGame, _mc:MovieClip, _origin:Point, _target:Point, _type:int=0, params:Object=null) 
		{
			params = new Object();
			params["velocity"] = 2;
			
			super(_cg, _mc, _origin, _target, _type, params);
			
			// override super
			dx = velocity * Math.cos(rot) * 2;
			dy = -velocity * Math.sin(rot) * 1.5;
			
			mc.rotation = Math.atan2(dy, dx);
			rot = degreesToRadians(mc.rotation);
			
			partType = "artillery";
			partCount = 2;
		}
		
		override public function step():Boolean
		{
			if (!markedForDestroy)
			{
				mc.x += dx;
				mc.y += dy;
				
				mc.rotation = Math.atan2(dy, dx) * 100;		// ???
				rot = degreesToRadians(mc.rotation);
				
				dy += gravity;
				
				if (Math.abs(mc.x) > 800)
					destroy();
					
				updateParticle(dx, dy);
				
				/*dist = getDistance(mc.x, mc.y, target.x, target.y);
				
				// TODO replace magic numbers
				if ((Math.abs(mc.x) > 800 || dist < 5 || dist > prevDist))
					destroy();
				else
					prevDist = dist;*/
			}
			
			return readyToDestroy;
		}
		
		override protected function updateParticle(dx:Number, dy:Number):void
		{
			if (partEnabled && --partCount == 0)
			{
				partCount = partInterval;
				cg.manPart.spawnParticle(partType, new Point(mc.x, mc.y), mc.rotation * 100, dx * .1, dy * .10, .05);
			}
		}
		
	}

}