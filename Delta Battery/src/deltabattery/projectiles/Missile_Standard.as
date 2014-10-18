package deltabattery.projectiles 
{
	import cobaltric.ContainerGame;
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	/**	Standard Missile
	 *
	 * 	Basic missile
	 * 	Player Weapon:	SAM
	 * 	Enemy:			Standard Missile (Wave 1+)
	 * 
	 * @author Alexander Huynh
	 */
	public class Missile_Standard extends ABST_Missile 
	{
		
		public function Missile_Standard(_cg:ContainerGame, _mc:MovieClip, _origin:Point, _target:Point, _type:int=0, params:Object=null) 
		{
			super(_cg, _mc, _origin, _target, _type, params);
		}
	}
}