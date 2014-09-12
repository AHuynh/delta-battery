package deltabattery.projectiles {
	import cobaltric.ContainerGame;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import org.flintparticles.twoD.renderers.DisplayObjectRenderer;
	
	/**	Chaingun bullet
	 * 
	 *	Standard Chaingun secondary weapon.
	 * 
	 * @author Alexander Huynh
	 */
	public class Bullet_Chain extends ABST_Bullet 
	{
		
		public function Bullet_Chain(_cg:ContainerGame, _mc:MovieClip, _dor:DisplayObjectRenderer, _origin:Point,
									 _target:Point, _type:int = 0, _life:int = 15, stats:Object = null) 
		{			
			super(_cg, _mc, _dor, _origin, _target, _type, _life, stats);
			
			
			// temporary tracer
			if (Math.random() > .8)
				mc.gotoAndStop("tracer");
				
			// TODO use stats
		}
	}
}