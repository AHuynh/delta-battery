package deltabattery.projectiles 
{
	import cobaltric.ContainerGame;
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	/**
	 * Bomber thingamajigger
	 * 
	 * @author Jesse Chen
	 */
	public class Bomber extends ABST_Missile 
	{
		private var timer:Number = 0;
		
		public function Bomber(_cg:ContainerGame, _mc:MovieClip, _origin:Point, _target:Point, _type:int=0, params:Object=null) {
			_target.y = _origin.y;
			
			if (params == null) {
				params = { velocity:(2 + Math.random()) };
			} 
			
			super(_cg, _mc, _origin, _target, _type, params);
		}
		
		override public function step():Boolean {
			if (!markedForDestroy) {
				// calculate and perform movement
				var dx:Number = velocity * Math.cos(rot);
				var dy:Number = velocity * Math.sin(rot);
				
				mc.x += dx;
				mc.y += dy;
				
				updateParticle(dx, dy);

				if (mc.x < 380 && timer % 90 == 0) {
					cg.manMiss.spawnProjectile("big", new Point(mc.x, mc.y), new Point(cg.game.city.x, cg.game.city.y));
				}
				
				if ((Math.abs(mc.x) > 800 || mc.y > 370)) {
					destroy();
				} 
			}
			
			timer++;
			
			// returns TRUE if this object needs to be removed
			return readyToDestroy;
		}
	}

}