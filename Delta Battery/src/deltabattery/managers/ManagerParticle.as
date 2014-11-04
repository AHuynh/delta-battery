package deltabattery.managers 
{
	import cobaltric.ContainerGame;
	import deltabattery.particles.Particle;
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Alexander Huynh
	 */
	public class ManagerParticle extends ABST_Manager 
	{
		private var particleFactory:Object;
		// a map from a key (below) to an array of the structure [[], []]
		// where	particleFactory[key][0] is an array of active particles (active),
		// 			particleFactory[key][1] is an array of stored particles (warehouse)
		// of type key
		
		// factory keys
		private const SMOKE:int		= 0;
		private const ARTY:int		= 1;
		
		public function ManagerParticle(_cg:ContainerGame) 
		{
			super(_cg);
			
			particleFactory = new Object();
			particleFactory[SMOKE] = [[], []];
			particleFactory[ARTY] = [[], []];
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
					particleFactory[part.factoryKey][0].splice(part.factoryIndex, 1);	// remove particle from active
					particleFactory[part.factoryKey][1].push(part);						// store particle in warehouse
				}
			}
		}
		
		/**	Spawn a particle (or use an existing, idle one from the warehouse if one exists)
		 * 
		 *	@proj		the type of projectile to spawn
		 * 	@origin		the starting location of the projectile
		 * 	@target		where the projectile will head toward
		 * 	@params		parameters for the projectile
		 */
		public function spawnParticle(proj:String, origin:Point, rot:Number = 0, dx:Number = 0, dy:Number = 0, g:Number = 0):void
		{
			// find the factory key
			var key:int;
			switch (proj)
			{
				case "artillery":	key = ARTY;		break;
				default:			key = SMOKE;
			}
			
			var particle:Particle;

			// use a stored, idle instance of the desired particle
			if (particleFactory[key][1].length != 0)
			{
				particle = particleFactory[key][1].pop();
				particle.reuse(origin, rot, dx, dy, g);
				addObject(particle);
			}
			// no desired particles are in the warehouse; manufacture a new one
			else
			{
				switch (key)
				{
					case ARTY:
						particle = addObject(new Particle(this, new ParticleArtillery(), origin, rot, dx, dy, g));
					break;
					default:		// SMOKE
						particle = addObject(new Particle(this, new ParticleSmoke01(), origin, 0, dx, dy, g));
				}
				
				particle.factoryIndex = particleFactory[key][0].length;
				particle.factoryKey = key;
				particleFactory[key][0].push(particle);
			}
		}
		
		private function addObject(p:Particle):Particle
		{
			objArr.push(p);
			cg.game.c_part.addChild(p.mc);
			return p;
		}
	}

}