package deltabattery.weapons 
{
	import cobaltric.ContainerGame;
	import deltabattery.SoundPlayer;
	import flash.geom.Point;
	
	/**	Standard secondary weapon
	 * 
	 * 	Chaingun
	 *
	 * @author Alexander Huynh
	 */
	public class Weapon_Chain extends ABST_Weapon 
	{
		public function Weapon_Chain(_cg:ContainerGame, _slot:int) 
		{
			super(_cg, _slot);
			name = "CHAIN";
			
			cooldownReset = 7;
			projectileLife = 15;
			ammo = ammoMax = 100;
		}
		
		override protected function createProjectile():void
		{
			cg.manBull.spawnProjectile("chain", new Point(turret.x, turret.y - 15),
												new Point(cg.mx, cg.my),
										TURRET_ID, projectileLife, projectileParams);
		}
	}
}