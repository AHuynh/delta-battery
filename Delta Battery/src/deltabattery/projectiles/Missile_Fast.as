package deltabattery.projectiles 
{
	import cobaltric.ContainerGame;
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	/**	Fast Missile
	 *
	 *  Missile with twice the standard velocity
	 * 	Enemy:			Fast Missile (Wave 4)     //TODO decide if wave 4 is a good place
	 * 
	 * @author Gavin Figueroa
	 */
	public class Missile_Fast extends ABST_Missile 
	{
		
		public function Missile_Fast(_cg:ContainerGame, _mc:MovieClip, _origin:Point, _target:Point, _type:int=0, params:Object=null) 
		{
			var newParams:Object = {veloctiy:(2 * (Math.random() * 2 + 4))};
			super(_cg, _mc, _origin, _target, _type, newParams);
		}
	}
}