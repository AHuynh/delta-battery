package deltabattery.projectiles 
{
	import cobaltric.ContainerGame;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import org.flintparticles.twoD.renderers.DisplayObjectRenderer;
	
	/**
	 * ...
	 * @author Alexander Huynh
	 */
	public class ABST_Artillery extends ABST_Missile 
	{
		protected var gravity:Number = .02;
		protected var dx:Number;
		protected var dy:Number;
		
		public function ABST_Artillery(_cg:ContainerGame, _mc:MovieClip, _dor:DisplayObjectRenderer, _origin:Point, _target:Point, _type:int=0, params:Object=null) 
		{
			params = new Object();
			params["velocity"] = 2;
			
			super(_cg, _mc, _dor, _origin, _target, _type, params);
			
			// override super
			mc.rotation = -45;		// TODO calculate
			rot = degreesToRadians(mc.rotation);
			
			dx = velocity * Math.cos(rot) * 2;
			dy = velocity * Math.sin(rot) * 1.5;
			
			trace("Artillery: " + Math.round(dx) + " " + Math.round(dy));
		}
		
		override public function step():Boolean
		{
			if (!markedForDestroy)
			{
				mc.x += dx;
				mc.y += dy;
				
				dy += gravity;
				
				if (emitter)
				{
					emitter.x = mc.x - 22 * Math.cos(rot);
					emitter.y = mc.y - 200;
				}
				
				if (Math.abs(mc.x) > 800)
					destroy();
				
				/*dist = getDistance(mc.x, mc.y, target.x, target.y);
				
				// TODO replace magic numbers
				if ((Math.abs(mc.x) > 800 || dist < 5 || dist > prevDist))
					destroy();
				else
					prevDist = dist;*/
			}
			
			return readyToDestroy;
		}
		
	}

}