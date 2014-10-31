package deltabattery.particles 
{
	import flash.display.MovieClip;
	import deltabattery.ABST_Base;
	import deltabattery.managers.ManagerParticle;
	import flash.geom.Point;
	
	/**	A MovieClip acting as a particle.
	 *
	 * 	Disappears once its animation is complete.
	 * 
	 *	@author Alexander Huynh
	 */
	public class Particle extends ABST_Base 
	{
		protected var man:ManagerParticle;
		public var mc:MovieClip;				// the actual particle MovieClip
		protected var mcTotal:int;				// mc.totalFrames
		
		public var dx:Number;	// amount to move the particle by per step
		public var dy:Number;
		public var g:Number;	// gravity
		
		public var rotSpd:Number = 0;
		
		public function Particle(_man:ManagerParticle, _mc:MovieClip, origin:Point, rot:Number, _dx:Number = 0, _dy:Number = 0, _g:Number = 0) 
		{
			super();
			man = _man;
			
			mc = _mc;
			mc.x = origin.x; mc.y = origin.y;
			
			dx = _dx; dy = _dy;
			g = _g;
			
			if (!rot)
			{
				mc.rotation = getRand( -180, 180);
				rotSpd = getRand( -.5, .5);
			}
			else
				mc.rotation = rot;
			
			mc.scaleX = mc.scaleY = getRand(.8, 1);
			mcTotal = mc.totalFrames;
		}
		
		// returns TRUE if this particle should be removed, FALSE otherwise
		public function step():Boolean
		{
			if (mc.currentFrame == mcTotal)
			{
				mc.stop();
				return true;
			}
			
			mc.rotation += rotSpd;
			
			mc.x += dx;
			mc.y += dy + g;
			return false;
		}
	}
}