package deltabattery.weapons
{
	import cobaltric.ContainerGame;
	import deltabattery.ABST_Base;
	import flash.display.MovieClip;
	/**	An abstract weapon used in Turret.as
	 *
	 * @author Alexander Huynh
	 */
	public class ABST_Weapon extends ABST_Base
	{		
		protected var cg:ContainerGame;	
		protected var turret:MovieClip;			// the Turret MovieClip
		protected const TURRET_ID:int = 1;		// type to use
		
		public var name:String;					// display name for the weapon (SAM, RAAM, Chain, etc.)
		public var slot:int;					// weapon slot
		
		public var cooldownCounter:int = 0;		// actual cooldown timer, 0 if ready to fire
		public var cooldownReset:int = 20;		// amount to set the cooldown to after firing
		
		public var projectileParams:Object = new Object();
		public var projectileLife:int = -1;
		public var projectileRange:int = -1;	// uses life to determine when to despawn
		
		public var ammoMax:int = 70;			// max reserve ammo
		public var ammo:int = ammoMax;			// current ammo

		public var costAmmo:int = 1;			// cost per 1 ammo for this weapon in the shop
		
		public function ABST_Weapon(_cg:ContainerGame, _slot:int) 
		{
			cg = _cg;
			turret = cg.game.mc_turret;
			slot = _slot;
			
			projectileParams["target"] = true
		}
		
		public function step():void
		{
			if (cooldownCounter > 0)		// GUI updated in Turret
				cooldownCounter--;
		}
		
		public function reload():void
		{
			cooldownCounter = 0;
		}

		// returns new remaining ammo, or -1 if couldn't fire
		public function fire():int
		{
			if (cooldownCounter > 0 || ammo == 0) return -1;

			createProjectile();
			cooldownCounter = cooldownReset;
			return --ammo;
		}
		
		protected function createProjectile():void
		{
			// -- override this function
		}
		
		// returns new remaining ammo
		// can also removeAmmo with a -amt
		public function addAmmo(amt:int):int
		{
			ammo += amt;
			if (ammo < 0)
				ammo = 0;
			else if (ammo > ammoMax)
				ammo = ammoMax;
			return ammo;
		}
	}
}