package deltabattery.projectiles {
	import deltabattery.ABST_Base;
	import deltabattery.managers.ManagerArtillery;
	import deltabattery.managers.ManagerMissile;
	import deltabattery.SoundPlayer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	
	/**	An abstract explosion
	 *
	 * 	Explosions		- kill all nearby missiles
	 * 					- disappear after their animation ends
	 * 					- usually do not affect bullets
	 * 					- usually do not move
	 * 
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
			SoundPlayer.play("sfx_explosion");
		}
		
		public function step(manMiss:ManagerMissile, manArty:ManagerArtillery):Boolean
		{
			var miss:ABST_Missile;			
			for (var i:int = manMiss.objArr.length - 1; i >= 0; i--)
			{
				miss = manMiss.objArr[i]
				if (type == miss.type) continue;

				if (getDistance(mc.x, mc.y, miss.mc.x, miss.mc.y) < range)
					miss.destroy();
			}
			
			var arty:ABST_Artillery;			
			for (var i:int = manArty.objArr.length - 1; i >= 0; i--)
			{
				arty = manArty.objArr[i]
				if (type == arty.type) continue;

				if (getDistance(mc.x, mc.y, arty.mc.x, arty.mc.y) < range)
					arty.destroy();
			}
				
			if (mc.currentFrame != mc.totalFrames) return false;
			
			if (par.contains(mc))
				par.removeChild(mc);

			return true;
		}
	}
}