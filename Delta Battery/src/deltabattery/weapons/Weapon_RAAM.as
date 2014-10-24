package deltabattery.weapons 
{
	import cobaltric.ContainerGame;
	import deltabattery.SoundPlayer;
	import flash.geom.Point;
	
	/**	Fast-travelling missile
	 * 
	 * 	Rapid Anti-Air Missile
	 *
	 * @author Alexander Huynh
	 */
	public class Weapon_RAAM extends ABST_Weapon 
	{
		public function Weapon_RAAM(_cg:ContainerGame, _slot:int) 
		{
			super(_cg, _slot);
			name = "RAAM";
			
			projectileParams["velocity"] = 18;
			projectileParams["partInterval"] = 2;
			projectileParams["explosionScale"] = .7;
			
			ammo = ammoMax = 30;
			cooldownReset = 45;
		}
		
		override protected function createProjectile():void
		{
			// -- TODO change?
			cg.manMiss.spawnProjectile("fastT", new Point(turret.x, turret.y - 15),
												   new Point(cg.mx, cg.my),
										TURRET_ID, projectileParams);
		}
		
	}

}