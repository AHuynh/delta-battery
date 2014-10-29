package deltabattery.managers
{
	import cobaltric.ContainerGame;
	import deltabattery.projectiles.*;
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	/**	Manager for a generic gravity-ignoring missile
	 * 
	 * @author Alexander Huynh
	 */
	public class ManagerMissile extends ABST_Manager 
	{	
		
		public function ManagerMissile(_cg:ContainerGame) 
		{
			super(_cg);
		}
		
		override public function step():void
		{			
			var miss:ABST_Missile;
			for (var i:int = objArr.length - 1; i >= 0; i--)
			{
				miss = objArr[i];
				if (miss.step())
				{
					if (cg.game.c_main.contains(miss.mc))
						cg.game.c_main.removeChild(miss.mc);
					objArr.splice(i, 1);
					miss = null;
				}
			}
		}
		
		/**	Spawn a gravity-ignoring missile
		 * 
		 *	@proj		the type of projectile to spawn with choices: [fast, fastT, big, rocket, standard, LASM]
		 * 	@origin		the starting location of the projectile
		 * 	@target		where the projectile will head toward
		 * 	@type		the affiliation that this projectile has (0 enemy; 1 player)
		 * 	@params		parameters for the projectile
		 */
		public function spawnProjectile(proj:String, origin:Point, target:Point, type:int = 0, params:Object = null):void
		{
			switch (proj)
			{
				case "fast":
					addObject(new Missile_Fast(cg, new MissileFast(), origin, target, type, params));
				break;
				case "fastT":	// turret RAAM
					addObject(new Missile_Standard(cg, new MissileFast(), origin, target, type, params));
				break;
				case "big":
					addObject(new Missile_Standard(cg, new MissileBig(), origin, target, type, params));
				break;
				case "rocket":
					addObject(new Missile_Fast(cg, new MissileRocket(), origin, target, type, params));
				break;
				case "cluster":
					addObject(new Missile_Cluster(cg, new MissileBig(), origin, target, type, params));	// TODO cluster GFX
				break;
				case "LASM":
					addObject(new Missile_LASM(cg, new MissileStandard(), origin, target, type, params));	// TODO LASM GFX
				break;
				case "bomber":
					addObject(new Vehicle_Bomber(cg, new Bomber(), origin, target, type, params));
				break;
				case "helicopter":
					addObject(new Vehicle_Helicopter(cg, new Helicopter(), origin, target, type, params));
				break;
				case "plane":
					addObject(new Vehicle_PlanePassenger(cg, new Airplane(), origin, target, type, params));
				break;
				default:		// "standard"
					addObject(new Missile_Standard(cg, new MissileStandard(), origin, target, type, params));
			}
		}
		
		private function addObject(a:ABST_Missile):void
		{
			objArr.push(a);
			cg.game.c_main.addChild(a.mc);
		}
	}
}