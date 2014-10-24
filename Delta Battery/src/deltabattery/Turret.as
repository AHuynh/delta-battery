package deltabattery 
{
	import cobaltric.ContainerGame;
	import deltabattery.weapons.ABST_Weapon;
	import deltabattery.weapons.Weapon_Chain;
	import deltabattery.weapons.Weapon_DeltaStrike;
	import deltabattery.weapons.Weapon_RAAM;
	import deltabattery.weapons.Weapon_SAM;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	/**	Controls aspects of the player's turret
	 *
	 * @author Alexander Huynh
	 */
	public class Turret extends ABST_Base
	{
		public var cg:ContainerGame;
		public var turret:MovieClip;			// the actual Turret MovieClip
		
		public var rightMouseDown:Boolean;		// TRUE if the right mouse is currently down
		
		// array of objects extending ABST_Weapons
		public var weaponPrimary:Array = [null, null, null];
		public var weaponSecondary:Array = [null, null, null];
		public var weaponSpecial:ABST_Weapon;
		
		private var weaponMC:Array;				// array of GUI objects (weapon icons)

		public var activePrimary:int = 0;		// index in array for LEFT
		public var activeSecondary:int = 0;		// index in array for RIGHT
		
		// turret rotation limits
		public const TURRET_LIMIT_R:Number = -90;		// straight up
		public const TURRET_LIMIT_L:Number = 175;		// slightly lower than directly left

		public function Turret(_cg:ContainerGame, _turret:MovieClip) 
		{
			cg = _cg;
			turret = _turret;
			turret.addEventListener(Event.ADDED_TO_STAGE, init);
			
			// setup default weapons
			weaponPrimary[0] = new Weapon_SAM(cg, 0);
			//weaponPrimary[1] = new Weapon_RAAM(cg, 1);		// TODO remove this weapon
			weaponSecondary[0] = new Weapon_Chain(cg, 0);
			weaponSpecial = new Weapon_DeltaStrike(cg);
		}
		
		
		/**
		 * 
		 * @param	weapon		the weapon to use
		 * @param	slot		0 <= slot <= 7
		 */
		public function enableWeapon(weapon:ABST_Weapon, slot:int):void
		{
			if (slot == 7)
				weaponSpecial = weapon;
			else if (slot == 6)
				return;
			else if (slot > 2)
				weaponSecondary[slot - 3] = weapon;
			else
				weaponPrimary[slot] = weapon;
			
			weaponMC[slot].visible = true;
		}
		
		private function init(e:Event):void
		{
			turret.removeEventListener(Event.ADDED_TO_STAGE, init);
			turret.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseLeftDown);
			turret.stage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onMouseRightDown);
			turret.stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onMouseRightUp);
			turret.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyboard);
			turret.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
			
			var gui:MovieClip = cg.game.mc_gui;
			weaponMC = [gui.wep_1, gui.wep_2, gui.wep_3, gui.wep_4, null, null, null, gui.wep_8];		// TODO complete
			
			// setup weapons
			weaponMC[1].gotoAndStop("raam");
			weaponMC[1].visible = false;
			weaponMC[2].gotoAndStop("big");
			weaponMC[2].visible = false;
			weaponMC[3].gotoAndStop("chain");
			weaponMC[7].gotoAndStop("delta");
			for (var i:int = 0; i < weaponMC.length; i++)
				if (weaponMC[i])
				{
					weaponMC[i].selected.visible = false;
					weaponMC[i].tf_number.text = (i+1);
				}
			weaponMC[0].selected.visible = true;
			weaponMC[3].selected.visible = true;
			weaponMC[7].selected.visible = true;
			weaponMC[7].tf_number.text = "S";
		}
		
		// called by ContainerGame
		public function step():void 
		{
			var i:int;
			if (rightMouseDown)
			{
				if (cg.game.mc_gui.newEnemy.visible) return;
				var newAmmo:int = weaponSecondary[activeSecondary].fire();
				weaponMC[3].ammo.y = 16.65 + (35 * (1 - (weaponSecondary[0].ammo / weaponSecondary[0].ammoMax)));
				if (newAmmo != -1)
					cg.game.mc_gui.tf_ammoS.text = newAmmo;
			}

			// update all weapons
			for (i = 0; i < 3; i++)
			{
				if (weaponPrimary[i])
				{
					weaponPrimary[i].step();
					weaponMC[i].reload.y = -20 + ((weaponPrimary[i].cooldownCounter / weaponPrimary[i].cooldownReset) * 40);
				}
				if (weaponSecondary[i])
				{
					weaponSecondary[i].step();
					weaponMC[i + 3].reload.y = -20 + ((weaponSecondary[i].cooldownCounter / weaponSecondary[i].cooldownReset) * 40);
				}
			}
			
			if (weaponSpecial)
			{
				weaponSpecial.step();
				weaponMC[7].reload.y = -20 + ((weaponSpecial.cooldownCounter / weaponSpecial.cooldownReset) * 40);
			}
		}

		private function onMouseLeftDown(e:MouseEvent):void
		{
			if (!cg.gameActive) return;
			if (cg.game.mc_gui.newEnemy.visible) return;
			var newAmmo:int = weaponPrimary[activePrimary].fire();
			if (newAmmo != -1)
			{
				cg.game.mc_gui.tf_ammoP.text = newAmmo;
				weaponMC[activePrimary].ammo.y = 16.65 + (35 * (1 - (weaponPrimary[activePrimary].ammo / weaponPrimary[activePrimary].ammoMax)));
				for (var i:int = 0; i < int(getRand(2, 4)) + 2; i++)
				{
					cg.manPart.spawnParticle("", new Point(turret.x + getRand(-5, 5), turret.y + getRand(-5, 5)), 0, getRand(0, 1), getRand(0, 1), .05);
				}
			}
		}
		
		// TEMP
		/*public function autoFire(tgtX:Number, tgtY:Number):void
		{
			var newAmmo:int = weaponPrimary[activePrimary].fire(tgtX, tgtY);
			if (newAmmo != -1)
				cg.game.mc_gui.tf_ammoP.text = newAmmo;
		}*/
		
		private function onMouseRightDown(e:MouseEvent):void
		{
			rightMouseDown = true;
		}
		
		private function onMouseRightUp(e:MouseEvent):void
		{
			rightMouseDown = false;
		}
		
		// called by Container Game
		public function updateMouse():void
		{
			if (!cg.gameActive) return;
			
			// face the turret towards the mouse
			var rot:Number = getAngle(0, 0, turret.mouseX, turret.mouseY);
			
			//var rot:Number = getAngle(0, 0, cg.mx, cg.my);
			/*if (Math.abs(rot) > TURRET_LIMIT_L)
				rot = TURRET_LIMIT_L;
			else if (rot > TURRET_LIMIT_R && turret.mouseX > turret.x)
				rot = TURRET_LIMIT_R;*/
			turret.mc_cannon.rotation = rot;
			//trace(TURRET_LIMIT_R + " | " + (rot + 360) + " | " + TURRET_LIMIT_L);
		}
		
		private function reloadAll():void
		{
			// reload all weapons
			for (var i:int = 0; i < 3; i++)
			{
				if (weaponPrimary[i])
				{
					weaponPrimary[i].reload();
					weaponMC[i].reload.y = 20;
				}
				if (weaponSecondary[i])
				{
					weaponSecondary[i].reload();
					weaponMC[i + 3].reload.y = 20;
				}
			}
			
			if (weaponSpecial)
			{
				weaponSpecial.reload();
				weaponMC[7].reload.y = 20;
			}
		}
		
		private function onKeyboard(e:KeyboardEvent):void
		{
			if (!cg.gameActive) return;
			
			var changed:int = -1;
			
			switch (e.keyCode)
			{
				case 32:	// SPACE
					var newAmmo:int = weaponSpecial.fire();
					weaponMC[7].ammo.y = 16.65 + (35 * (1 - (weaponSpecial.ammo / weaponSpecial.ammoMax)));
				break;
				case 49:	// 1
					if (weaponPrimary[0])
					{
						activePrimary = 0;
						changed = 0;
						cg.game.mc_gui.tf_weaponP.text = weaponPrimary[activePrimary].name;
						cg.game.mc_gui.tf_ammoP.text = weaponPrimary[activePrimary].ammo;
					}
				break;
				case 50: 	// 2
					if (weaponPrimary[1])
					{
						activePrimary = 1;
						changed = 1;
						cg.game.mc_gui.tf_weaponP.text = weaponPrimary[activePrimary].name;
						cg.game.mc_gui.tf_ammoP.text = weaponPrimary[activePrimary].ammo;
					}
				break;
				case 51:	// 3
					if (weaponPrimary[2])
					{
						activePrimary = 2;
						changed = 2;
						cg.game.mc_gui.tf_weaponP.text = weaponPrimary[activePrimary].name;
						cg.game.mc_gui.tf_ammoP.text = weaponPrimary[activePrimary].ammo;
					}
				break;
			}
		
			if (changed == -1) return;
			for (var i:int = 0; i < 3; i++)		// TODO change 3
				if (weaponMC[i])
					weaponMC[i].selected.visible = false;
			weaponMC[changed].selected.visible = true;
		}
		
		private function destroy(e:Event):void
		{
			cg = null;
			if (turret.stage)
			{
				turret.stage.removeEventListener(MouseEvent.CLICK, onMouseLeftDown);
				turret.stage.removeEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onMouseRightDown);
				turret.stage.removeEventListener(MouseEvent.RIGHT_MOUSE_UP, onMouseRightUp);
			}
			turret.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			turret = null;
		}
	}
}