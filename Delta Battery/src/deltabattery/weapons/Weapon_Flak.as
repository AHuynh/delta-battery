package deltabattery.weapons 
{
	import cobaltric.ContainerGame;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Alexander Huynh
	 */
	public class Weapon_Flak extends ABST_Weapon 
	{
		
		public function Weapon_Flak(_cg:ContainerGame, _slot:int) 
		{
			super(_cg, _slot);
			name = "FLAK";
			
			cooldownReset = 14;
			projectileLife = 30 + getRand(0, 10);
			ammo = ammoMax = 40;
			
		}
		
		override protected function createProjectile():void
		{
			cg.manBull.spawnProjectile("flak", new Point(turret.x, turret.y - 15),
											   new Point(cg.mx, cg.my ),
										TURRET_ID, projectileLife, projectileParams);
		}
	}
}