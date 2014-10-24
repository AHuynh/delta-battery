package deltabattery.weapons 
{
	import cobaltric.ContainerGame;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Alexander Huynh
	 */
	public class Weapon_HES extends ABST_Weapon 
	{
		public function Weapon_HES(_cg:ContainerGame, _slot:int) 
		{
			super(_cg, _slot);
			name = "HE-S";
			
			projectileParams["velocity"] = 6;
			projectileParams["partInterval"] = 7;
			projectileParams["explosionScale"] = 2.25;		// TODO use different, slower explosion?
			
			ammo = ammoMax = 25;
			cooldownReset = 60;
		}
		
		override protected function createProjectile():void
		{
			cg.manMiss.spawnProjectile("big", new Point(turret.x, turret.y - 15),
										new Point(cg.mx, cg.my),
										TURRET_ID, projectileParams);
		}
		
	}

}