package deltabattery 
{
	import cobaltric.ContainerGame;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Alexander Huynh
	 */
	public class ManagerMissile extends ABST_Manager 
	{	
		private var manExpl:ManagerExplosion;
		
		public function ManagerMissile(_cg:ContainerGame, _manExpl:ManagerExplosion) 
		{
			super(_cg);
			manExpl = _manExpl;
		}
		
		override public function step():void
		{
			// -- TEMPORARY TESTING
			if (Math.random() > .99)
				spawnMissile(new Point(450, -300 + getRand(0, 150)), new Point(-440 + getRand(10), 200 + getRand(0, 100)));
			
			var miss:ABST_Missile;
			for (var i:int = objArr.length - 1; i >= 0; i--)
			{
				miss = objArr[i];
				if (miss.step(manExpl))
				{
					if (cg.game.c_main.contains(miss.mc))
						cg.game.c_main.removeChild(miss.mc);
					objArr.splice(i, 1);
					miss = null;
				}
			}
		}
		
		public function spawnMissile(origin:Point, target:Point, type:int = 0, params:Object = null):void
		{
			var m:ABST_Missile = new ABST_Missile(cg, new MissileStandard(), cg.renderer, origin, target, type, params);
			objArr.push(m);
			cg.game.c_main.addChild(m.mc);
		}
	}
}