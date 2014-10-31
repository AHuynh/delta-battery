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
			
			super(_cg, _mc, _origin, _target, _type, params);
			
			mc.rotation = radiansToDegrees(Math.atan2(dy, dx));
			
			partType = "artillery";
			partCount = 2;
		}
		
		override public function step():Boolean
		{
			if (!markedForDestroy)
			{
				mc.x += dx;
				mc.y += dy;
				dy += gravity;
				
				mc.rotation = radiansToDegrees(Math.atan2(dy, dx));

				if (Math.abs(mc.x) > 800 || mc.y > 170)
					destroy();
					
				updateParticle(dx, dy);
				checkTarget();
			}
			
			return readyToDestroy;
		}
		
		override protected function updateParticle(dx:Number, dy:Number):void
		{
			if (partEnabled && --partCount == 0)
			{
				partCount = partInterval;
				cg.manPart.spawnParticle(partType, new Point(mc.x, mc.y), mc.rotation, dx * .1, dy * .10, .05);
			}
		}
		
	}

}