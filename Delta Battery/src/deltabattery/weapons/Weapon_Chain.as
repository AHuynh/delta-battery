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
		public var weaponSway:int = 40;
		
		public function Weapon_Chain(_cg:ContainerGame, _slot:int) 
		{
			super(_cg, _slot);
			name = "CHAIN";
			
			cooldownReset = 10;
			projectileLife = 13;
			ammo = ammoMax = ammoBase = 50;
		}
		
		override protected function createProjectile():void
		{
			cg.manBull.spawnProjectile("chain", new Point(turret.x, turret.y - 15),
												new Point(cg.mx + getRand( -weaponSway * .5, weaponSway * .5),
														  cg.my + getRand( -weaponSway * .5, weaponSway * .5)),
										TURRET_ID, projectileLife, projectileParams);
		}
	}
}