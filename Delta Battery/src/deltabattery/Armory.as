package deltabattery 
{
	import cobaltric.ContainerGame;
	import deltabattery.weapons.ABST_Weapon;
	import deltabattery.weapons.Weapon_Flak;
	import deltabattery.weapons.Weapon_HES;
	import deltabattery.weapons.Weapon_RAAM;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;

	/**
	 * Controls the shop with new weapons and upgrades.
	 * 
	 * Buying weapons
	 * Any of the 4 extra weapons can be bought for the same price.
	 * Subsequent purchases are more expensive. (wepPrices)
	 * 
	 * Buying upgrades
	 * Each upgrade attribute has an individual upgrade price.
	 * 
	 * @author Alexander Huynh
	 */
	public class Armory 
	{
		private var cg:ContainerGame;
		private var arm:MovieClip;
		
		private var wepArr:Array;	// list of weapon buttons
		private var selArr:Array;	// list of 'selected' MC's on weapon buttons
		private var ammArr:Array;	// list of ammo TextFields
		private var upgArr:Array;	// list of upgrade buttons
		private var lvlArr:Array;	// list of upgrade levels
		
		private var wepStatus:Array = [false, false, false, false];
									// fast  big   flak  laser
									// true if purchased
		private const wepPrices:Array = [1000, 2500, 5000, 10000];						  
									// cost to buy the 1st, 2nd, etc weapon
		private const wepCount:int = 0;		// number of weapons bought
		
		private var upgCost:Array = [500, 700, 900];
								  // expl speed reload
		
		private var upgLevel:Array = [1, 1, 1];
								 // exp spd rel
								 
		private var boi:String;		// button of interest
		
		public function Armory(_cg:ContainerGame) 
		{
			cg = _cg;
			arm = cg.game.mc_gui.shop;
			
			// setup armory MovieClip
			arm.tf_title.text = "";
			arm.tf_subtitle.text = "";
			arm.tf_desc.text = "Click an item to view information.";
			arm.btn_purchase.visible = false;
			arm.ammoGroup.visible = false;
			arm.tf_price.text = "";
			
			wepArr = [arm.btn_arm_fast, arm.btn_arm_big,
					  arm.btn_arm_flak, arm.btn_arm_laser];
			selArr = [];
			
			ammArr = [arm.ammoGroup.tf_l, arm.ammoGroup.tf_c, arm.ammoGroup.tf_r];
			
			upgArr = [arm.btn_arm_explosion, arm.btn_arm_speed,
					  arm.btn_arm_reload];
			lvlArr = [arm.lvl_explosion, arm.lvl_speed,
					  arm.lvl_reload];
			
			arm.btn_purchase.addEventListener(MouseEvent.CLICK, onPurchase);
			arm.mc_tutorial.btn_resume.addEventListener(MouseEvent.CLICK, onResume);
		}
		
		private function addSelected(btn:SimpleButton, showX:Boolean):void
		{
			var select:MovieClip = new Selected();
			select.x = btn.x; select.y = btn.y;
			select.buttonMode = select.mouseEnabled = select.mouseChildren = false;
			select.lock.visible = showX;
			selArr.push(select);
			arm.addChild(select);
		}
		
		// acknowledge Armory upgrade guide
		private function onResume(e:MouseEvent):void
		{
			arm.mc_tutorial.visible = false;
			arm.mc_tutorial.btn_resume.removeEventListener(MouseEvent.CLICK, onResume);
					  
			// add 'selected' overlays
			var select:MovieClip;
			var i:int;
			for (i = 0; i < wepArr.length; i++)
			{
				wepArr[i].addEventListener(MouseEvent.CLICK, onWeapon);
				addSelected(wepArr[i], true);
			}
			for (i = 0; i < upgArr.length; i++)
			{
				upgArr[i].addEventListener(MouseEvent.CLICK, onUpgrade);
				addSelected(upgArr[i], false);
				lvlArr[i].buttonMode = lvlArr[i].mouseEnabled = lvlArr[i].mouseChildren = false;
			}
		}
		
		/**
		 * Callback when a button is pressed.
		 * @param	e	the corresponding MouseEvent
		 */
		private function onWeapon(e:MouseEvent):void
		{
			var ind:int = -1;
			switch (e.target.name)
			{
				case "btn_arm_fast":
					arm.tf_title.text = "RAAM";
					arm.tf_subtitle.text = "Rapid Anti-Air Missile";
					arm.tf_desc.text = "A very fast missile, good at long range.\n\n" +
									   "Because it was made to be fast and light, the " +
									   "RAAM has a smaller explosive payload."
					ind = 0;
				break;
				case "btn_arm_big":
					arm.tf_title.text = "HE-S";
					arm.tf_subtitle.text = "High Explosive Striker";
					arm.tf_desc.text = "A slow but high-yield missile.\n\n" +
									   "The HE-S creates a very large explosion " +
									   "at the expense of travel speed."
					ind = 1;
				break;
				case "btn_arm_flak":
					arm.tf_title.text = "FLAK";
					arm.tf_subtitle.text = "Flak Gun";
					arm.tf_desc.text = "An area-of-effect cannon.\n\n" +
									   "The Flak gun excels at saturating areas. " +
									   "However, its accuracy is very low."
					ind = 2;
				break;
				case "btn_arm_laser":
					arm.tf_title.text = "LASER";
					arm.tf_subtitle.text = "Needlehead Laser";
					arm.tf_desc.text = "A powerful and precise laser.\n\n" +
									   "The Needlehead is a surgical-strike weapon with " +
									   "very low area-of-effect but extreme accuracy."
					ind = 3;
				break;
			}
			
			if (ind == -1) return;
			
			// update lower right panel
			arm.btn_purchase.visible = !wepStatus[ind];
			arm.ammoGroup.visible = wepStatus[ind];
			arm.tf_price.text = !wepStatus[ind] ? "$" + wepPrices[wepCount] : "";
			
			// update ammo if weapon is purchased
			if (wepStatus[ind])
			{
				/*ammArr[0].text = cg.turret.
				ammArr[1].text =
				ammArr[2].text =*/
			}
			
			boi = arm.tf_title.text;						// set button of interest
			for (var i:int = 0; i < selArr.length; i++)		// update overlays
				selArr[i].gotoAndStop("unselected");
			selArr[ind].gotoAndPlay("selected");
		}
		
		/**
		 * Callback when a button is pressed.
		 * @param	e	the corresponding MouseEvent
		 */
		private function onUpgrade(e:MouseEvent):void
		{
			var ind:int = -1;
			switch (e.target.name)
			{
				case "btn_arm_explosion":
					arm.tf_title.text = "+EXP";
					arm.tf_subtitle.text = "Upgrade explosion size";
					arm.tf_desc.text = "Increases explosion size for turret weapons.";
					ind = 0;
				break;
				case "btn_arm_speed":
					arm.tf_title.text = "+SPD";
					arm.tf_subtitle.text = "Upgrade flight speed";
					arm.tf_desc.text = "Increases the speed of turret projectiles";
					ind = 1;
				break;
				case "btn_arm_reload":
					arm.tf_title.text = "+REL";
					arm.tf_subtitle.text = "Upgrade reload speed";
					arm.tf_desc.text = "Decreases the reload time of turret weapons.";
					ind = 2;
				break;
			}
			if (ind == -1) return;
			arm.btn_purchase.visible = true;
			arm.ammoGroup.visible = false;
			arm.tf_price.text = "$" + upgCost[ind];
			boi = arm.tf_title.text;
			
			boi = arm.tf_title.text;						// set button of interest
			for (var i:int = 0; i < selArr.length; i++)		// update overlays
				selArr[i].gotoAndStop("unselected");
			selArr[ind+4].gotoAndPlay("selected");
		}
		
		private function onPurchase(e:MouseEvent):void
		{
			if (!boi) return;
	
			var price:int = int(arm.tf_price.text.substring(1));
			if (price > cg.money) return;
	
			var aoi:Array;		// array of interest 
			var ioi:int;		// index of interest
			
			var slot:int;
			var weapon:ABST_Weapon;
			
			switch (boi)
			{
				case "RAAM":
					aoi = wepArr;
					ioi = 0;
					weapon = new Weapon_RAAM(cg, 1);		// TODO complete for others
					slot = 1;
				break;
				case "HE-S":
					aoi = wepArr;
					ioi = 1;
					weapon = new Weapon_HES(cg, 2);
					slot = 2;
				break;
				case "FLAK":
					aoi = wepArr;
					ioi = 2;
					weapon = new Weapon_Flak(cg, 4);
					slot = 4;
				break;
				case "LASER":
					aoi = wepArr;
					ioi = 3;
				break;
				case "+EXP":
					aoi = upgArr;
					ioi = 0;
				break;
				case "+SPD":
					aoi = upgArr;
					ioi = 1;
				break;
				case "+REL":
					aoi = upgArr;
					ioi = 2;
				break;
			}
			
			cg.addMoney( -price);
			
			// if a weapon was selected with index ioi
			if (aoi == wepArr)
			{
				cg.turret.enableWeapon(weapon, slot);
				selArr[ioi].lock.visible = false;
				wepStatus[ioi] = true;
				
				arm.btn_purchase.visible = false;
				arm.ammoGroup.visible = true;
				arm.tf_price.text = "";	
			}
		}
	}
}