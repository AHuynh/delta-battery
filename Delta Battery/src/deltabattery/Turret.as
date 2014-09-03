package deltabattery 
{
	import cobaltric.ContainerGame;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Alexander Huynh
	 */
	public class Turret extends ABST_Base
	{
		public var cg:ContainerGame;
		public var turret:MovieClip;
		
		public const TURRET_LIMIT_L:Number = 0;
		public const TURRET_LIMIT_R:Number = -95;
		
		public var missileParams:Object;
		
		public function Turret(_cg:ContainerGame, _turret:MovieClip) 
		{
			cg = _cg;
			turret = _turret;
			turret.addEventListener(Event.ADDED_TO_STAGE, init);
			
			missileParams = new Object();
			missileParams["velocity"] = 7;
		}
		
		private function init(e:Event):void
		{
			turret.removeEventListener(Event.ADDED_TO_STAGE, init);
			turret.stage.addEventListener(MouseEvent.CLICK, onMouse);
			turret.stage.addEventListener(MouseEvent.RIGHT_CLICK, onMouseRight);
			turret.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
		}
		
		// called by Container Game
		public function updateMouse():void
		{
			var rot:Number = getAngle(0, 0, turret.mouseX, turret.mouseY);
			if (rot > TURRET_LIMIT_L)
				rot = TURRET_LIMIT_L;
			else if (rot < TURRET_LIMIT_R)
				rot = TURRET_LIMIT_R;
			turret.mc_cannon.rotation = rot;
		}
		
		private function onMouse(e:MouseEvent):void
		{
			trace(e.type);
			cg.manMiss.spawnMissile(new Point(turret.x, turret.y - 15), new Point(cg.mouseX, cg.mouseY), 1, missileParams);
		}
		
		private function onMouseRight(e:MouseEvent):void
		{
			trace("Right");
		}
		
		private function destroy(e:Event):void
		{
			if (turret.stage)
				turret.stage.removeEventListener(MouseEvent.CLICK, onMouse);
			turret.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
		}
	}
}