package deltabattery 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Alexander Huynh
	 */
	public class ABST_Explosion extends ABST_Base 
	{
		public var par:MovieClip;
		public var mc:MovieClip;
		public var type:int;
		
		public var range:int;
		
		private var origin:Point;
		
		public function ABST_Explosion(_par:MovieClip, _mc:MovieClip, _origin:Point, _type:int = 0) 
		{
			par = _par;
			mc = _mc;		
			origin = _origin;
			
			type = _type;
			
			mc.x = origin.x;
			mc.y = origin.y;
			
			range = 30;		// TODO set dynamically
		}
		
		public function step(manMiss:ManagerMissile):Boolean
		{
			var miss:ABST_Missile;
			
			for (var i:int = manMiss.objArr.length - 1; i >= 0; i--)
			{
				miss = manMiss.objArr[i]
				if (type == miss.type) continue;

				if (getDistance(mc.x, mc.y, miss.mc.x, miss.mc.y) < range)
					miss.destroy();
			}
				
			if (mc.currentFrame != mc.totalFrames) return false;
			
			if (par.contains(mc))
				par.removeChild(mc);

			return true;
		}
	}
}