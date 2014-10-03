package deltabattery.projectiles {
	import cobaltric.ContainerGame;
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	/**	An abstract bullet
	 * 
	 *	Bullets		- kill all missiles they pass through
	 * 				- continue towards and pass their target
	 * 				- usually do not explode
	 * 				- disappear after their life reaches 0
	 * 				- ignore gravity
	 * 
	 * @author Alexander Huynh
	 */
	public class ABST_Bullet extends ABST_Missile 
	{
		private var life:int;
		
		public function ABST_Bullet(_cg:ContainerGame, _mc:MovieClip, _origin:Point, _target:Point, 
									_type:int = 0, _life:int = 15, stats:Object = null) 
		{
			life = _life;
			var params:Object = new Object();
			
			params["target"] = false;		// don't show target reticule
			params["useEmitter"] = false;	// don't create particles
			params["velocity"] = 25;
			params["explode"] = false;		// don't explode
			
			super(_cg, _mc, _origin, _target, _type, params);
			
			// -- TODO use stats
		}
		
		override public function step():Boolean
		{
			if (!markedForDestroy)
			{
				mc.x += velocity * Math.cos(rot);
				mc.y += velocity * Math.sin(rot);
				
				life--;
				
				// TODO replace magic numbers
				if (life <= 0 || (Math.abs(mc.x) > 500))
					destroy();
			}
			
			return readyToDestroy;
		}
		
		override public function destroy():void
		{
			cleanup(null);
		}
	}
}