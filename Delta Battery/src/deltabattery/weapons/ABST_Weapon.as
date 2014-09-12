package deltabattery.weapons
{
	import cobaltric.ContainerGame;
	import flash.display.MovieClip;
	/**	An abstract weapon used in Turret.as
	 *
	 * @author Alexander Huynh
	 */
	public class ABST_Weapon 
	{		
		protected var cg:ContainerGame;
		protected var turret:MovieClip;
		protected const TURRET_ID:int = 1;
		
		public var name:String;
		public var slot:int;		// weapon slot
		
		public var cooldownCounter:int = 0;
		public var cooldownReset:int = 15;
		
		public var useHeat:Boolean = false;
		public var heat:Number = 0;
		public var heatMax:Number = 0;
		public var heatReduce:Number = 0;
		
		public var projectileParams:Object = new Object();
		public var projectileLife:int = -1;
		public var projectileRange:int = -1;
		
		public var ammoMax:int = 100;
		public var ammo:int = ammoMax;

		public var cost:int = 0;

		public function ABST_Weapon(_cg:ContainerGame, _slot:int) 
		{
			cg = _cg;
			turret = cg.game.mc_turret;
			slot = _slot;
		}
		
		public function step():void
		{
			if (cooldownCounter > 0)
			{
				cooldownCounter--;
				// -- TODO update cooldown indicator
			}

			if (useHeat && heat > 0)		// TODO update heat indicator
			{
				heat -= heatReduce;
				if (heat < 0)
					heat = 0;
			}
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