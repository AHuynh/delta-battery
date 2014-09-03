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
		
		public var rightMouseDown:Boolean;
		
		public var ammoPrimary:Array = [100, 0, 0];
		public var ammoSecondary:Array = [200, 0, 0];
		
		public var activePrimary:int = 0;		// index in array
		public var activeSecondary:int = 0;		// index in array
		
		// TODO use array
		public var cooldownRight:int;
		public var resetRight:int;
		
		public const TURRET_LIMIT_L:Number = 0;
		public const TURRET_LIMIT_R:Number = -95;
		
		public var missileParams:Object;
		
		public function Turret(_cg:ContainerGame, _turret:MovieClip) 
		{
			cg = _cg;
			turret = _turret;
			turret.addEventListener(Event.ADDED_TO_STAGE, init);
			
			cooldownRight = 0;
			resetRight = 7;
			
			missileParams = new Object();
			missileParams["velocity"] = 7;
		}
		
		private function init(e:Event):void
		{
			turret.removeEventListener(Event.ADDED_TO_STAGE, init);
			turret.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouse);
			turret.stage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onMouseRightDown);
			turret.stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onMouseRightUp);
			turret.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
		}
		
		public function step():void
		{
			if (cooldownRight > 0)
				cooldownRight--;
			else if (rightMouseDown && ammoSecondary[activeSecondary] > 0)
			{
				ammoSecondary[activeSecondary]--;
				cg.game.mc_gui.tf_ammoS.text = ammoSecondary[activeSecondary];
				
				cg.manBull.spawnProjectile("chain", new Point(turret.x, turret.y - 15), new Point(cg.mouseX, cg.mouseY), 1);
				cooldownRight = resetRight;
			}
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
			if (ammoPrimary[activePrimary] > 0)
			{
				ammoPrimary[activePrimary]--;
				cg.game.mc_gui.tf_ammoP.text = ammoPrimary[activePrimary];
				
				cg.manMiss.spawnProjectile("standard", new Point(turret.x, turret.y - 15), new Point(cg.mouseX, cg.mouseY), 1, missileParams);
			}
			trace(cg.mouseX + " " + cg.mouseY);
		}
		
		private function onMouseRightDown(e:MouseEvent):void
		{
			rightMouseDown = true;
		}
		
		private function onMouseRightUp(e:MouseEvent):void
		{
			rightMouseDown = false;
		}
		
		private function destroy(e:Event):void
		{
			if (turret.stage)
				turret.stage.removeEventListener(MouseEvent.CLICK, onMouse);
			turret.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
		}
	}
}