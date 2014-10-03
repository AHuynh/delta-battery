package deltabattery.projectiles 
{
	import cobaltric.ContainerGame;
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	/**	Standard artillery projectile
	 *
	 * 	Basic arillery
	 *	Enemy: 		Standard Artillery (Wave 2+)
	 * 
	 * @author Alexander Huynh
	 */
	public class Artillery_Standard extends ABST_Artillery 
	{
		public function Artillery_Standard(_cg:ContainerGame, _mc:MovieClip, _origin:Point, _target:Point, _type:int=0, params:Object=null) 
		{
			super(_cg, _mc, _origin, _target, _type, params);		
		}
	}
}