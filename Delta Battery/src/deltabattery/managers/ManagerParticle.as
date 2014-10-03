package deltabattery.managers 
{
	import cobaltric.ContainerGame;
	import deltabattery.particles.Particle;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Alexander Huynh
	 */
	public class ManagerParticle extends ABST_Manager 
	{
		
		public function ManagerParticle(_cg:ContainerGame) 
		{
			super(_cg);
		}
		
		override public function step():void
		{			
			var part:Particle;
			for (var i:int = objArr.length - 1; i >= 0; i--)
			{
				part = objArr[i];
				if (part.step())
				{
					if (cg.game.c_part.contains(part.mc))
						cg.game.c_part.removeChild(part.mc);
					objArr.splice(i, 1);
					part = null;
				}
			}
		}
		
		/**	Spawn a particle
		 * 
		 *	@proj		the type of projectile to spawn
		 * 	@origin		the starting location of the projectile
		 * 	@target		where the projectile will head toward
		 * 	@params		parameters for the projectile
		 */
		public function spawnParticle(proj:String, origin:Point, rot:Number = 0, dx:Number = 0, dy:Number = 0, g:Number = 0):void
		{
			switch (proj)
			{
				case "artillery":
					addObject(new Particle(this, new ParticleArtillery(), origin, rot, dx, dy, g));
				break;
				default:		// "standard"
					addObject(new Particle(this, new ParticleSmoke01(), origin, 0, dx, dy, g));
			}
		}
		
		private function addObject(p:Particle):void
		{
			objArr.push(p);
			cg.game.c_part.addChild(p.mc);
		}
	}

}