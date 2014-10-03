package deltabattery.particles 
{
	import flash.display.MovieClip;
	import deltabattery.ABST_Base;
	import deltabattery.managers.ManagerParticle;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Alexander Huynh
	 */
	public class Particle extends ABST_Base 
	{
		protected var man:ManagerParticle;
		public var mc:MovieClip;
		protected var mcTotal:int;		// mc.totalFrames
		
		public var dx:Number;
		public var dy:Number;
		public var g:Number;	// gravity
		
		public var rotSpd:Number = 0;
		
		public function Particle(_man:ManagerParticle, _mc:MovieClip, origin:Point, rot:Number = 0, _dx:Number = 0, _dy:Number = 0, _g:Number = 0) 
		{
			super();
			man = _man;
			
			mc = _mc;
			mc.x = origin.x; mc.y = origin.y;
			
			dx = _dx; dy = _dy;
			g = _g;
			
			if (rot == 0)
			{
				mc.rotation = getRand( -180, 180);
				rotSpd = getRand( -.5, .5);
			}
			mc.scaleX = mc.scaleY = getRand(.8, 1);
			
			
			mcTotal = mc.totalFrames;
		}
		
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