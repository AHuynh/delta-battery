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
		private var upgArr:Array;	// list of upgrade buttons
		private var lvlArr:Array;	// list of upgrade levels MC's
		
		// TRUE if weapon was purchased, FALSE otherwise
		private var wepStatus:Array = [false, false, false, false];
									// fast  big   flak  laser
									
		// cost to buy the 1st, 2nd, etc weapon						
		private const wepPrices:Array = [1000, 5000, 10000, 25000];	
		private var wepCount:int = 0;		// number of weapons bought
		
		// cost of each individual upgrade (index + 1 -> level)
		private var upgCost:Array = [[200, 300, 500, 750, 1000, 1500, 2500, 4000, 7000],	// explosion
									 [250, 375, 600, 900, 1250, 1750, 3000, 5000, 9000],	// speed
									 [200, 400, 750, 900, 1200, 1700, 3200, 5500, 9000],	// reload
									 [150, 250, 400, 650,  900, 1300, 1900, 2600, 4000]];	// ammo
									 
		// modifier of each upgrade (index -> level)
		public var upgMod:Array = [[1, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.85, 2],		// explosion
								   [1, 1.1, 1.2, 1.3, 1.45, 1.6, 1.75, 1.9, 2.1, 2.5],	// speed
								   [1, 1.15, 1.3, 1.45, 1.6, 1.75, 2, 2.25, 2.5, 2.75],		// reload
								   [1, 1.2, 1.35, 1.5, 1.75, 2, 2.5, 3, 3.5, 4]];		// ammo
		
		public var upgLevel:Array = [0, 0, 0, 0];
								 // exp spd rel, ammo
								 
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
			arm.tf_price.text = "";
			
			wepArr = [arm.btn_arm_fast, arm.btn_arm_big,
					  arm.btn_arm_flak, arm.btn_arm_laser];
			selArr = [];
			
			upgArr = [arm.btn_arm_explosion, arm.btn_arm_speed,
					  arm.btn_arm_reload, arm.btn_arm_ammo];
			lvlArr = [arm.lvl_explosion, arm.lvl_speed,
					  arm.lvl_reload, arm.lvl_ammo];
			
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
			
			// put acknowledge above everything
			arm.setChildIndex(arm.acknowledge, arm.numChildren - 1);
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
			arm.tf_price.text = !wepStatus[ind] ? "$" + wepPrices[wepCount] : "Owned!";

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
			var ind:int = setUpgDesc(e.target.name);
			if (ind == -1) return;

			arm.btn_purchase.visible = upgLevel[ind] < 9;
			arm.tf_price.text = arm.btn_purchase.visible ? "$" + upgCost[ind][upgLevel[ind]] : "MAX LVL";
			
			boi = arm.tf_title.text;						// set button of interest
			for (var i:int = 0; i < selArr.length; i++)		// update overlays
				selArr[i].gotoAndStop("unselected");
			selArr[ind+4].gotoAndPlay("selected");
		}
		
		private function setUpgDesc(s:String):int
		{
			trace("Got: " + s);
			switch (s)
			{
				case "btn_arm_explosion":
					arm.tf_title.text = "EXP Lv." + upgLevel[0];
					arm.tf_subtitle.text = "Upgrade explosion size";
					arm.tf_desc.text = "Bigger explosions can hit more targets.\n\n\n\n" +
									   "Explosion size\n" +
									   "Current:\tx" + upgMod[0][upgLevel[0]].toFixed(2) +
									   (upgLevel[0] < 9 ? "\nNext:\t\tx" + upgMod[0][upgLevel[0] + 1].toFixed(2) : "");
					return 0;
				break;
				case "btn_arm_speed":
					arm.tf_title.text = "SPD Lv." + upgLevel[1];
					arm.tf_subtitle.text = "Upgrade flight speed";
					arm.tf_desc.text = "Faster projectiles make it easier to hit targets.\n\n\n\n" +
									   "Projectile velocity\n" +
									   "Current:\tx" + upgMod[1][upgLevel[1]].toFixed(2) +
									   (upgLevel[1] < 8 ? "\nNext:\t\tx" + upgMod[1][upgLevel[1] + 1].toFixed(2) : "");
					return 1;
				break;
				case "btn_arm_reload":
					arm.tf_title.text = "REL Lv." + upgLevel[2];
					arm.tf_subtitle.text = "Upgrade reload speed";
					arm.tf_desc.text = "Faster reload speeds let you shoot more often.\n\n\n" +
									   "Reload speed\n" +
									   "Current:\tx" + upgMod[2][upgLevel[2]].toFixed(2) +
									   (upgLevel[2] < 8 ? "\nNext:\t\tx" + upgMod[2][upgLevel[2] + 1].toFixed(2) : "");
					return 2;
				break;
				case "btn_arm_ammo":
					arm.tf_title.text = "AMM Lv." + upgLevel[3];
					arm.tf_subtitle.text = "Upgrade ammo reserve";
					arm.tf_desc.text = "Higher ammo stores make it harder to go empty.\n\n\n" +
									   "Ammo count\n" +
									   "Current:\tx" + upgMod[3][upgLevel[3]].toFixed(2) +
									   (upgLevel[3] < 8 ? "\nNext:\t\tx" + upgMod[3][upgLevel[3] + 1].toFixed(2) : "");
					return 3;
				break;
			}	
			return -1;
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
			
			switch (boi.substring(0, 3))
			{
				case "RAA":
					aoi = wepArr;
					ioi = 0;
					weapon = new Weapon_RAAM(cg, 1);		// TODO complete for others
					slot = 1;
				break;
				case "HE-":
					aoi = wepArr;
					ioi = 1;
					weapon = new Weapon_HES(cg, 2);
					slot = 2;
				break;
				case "FLA":
					aoi = wepArr;
					ioi = 2;
					weapon = new Weapon_Flak(cg, 4);
					slot = 4;
				break;
				case "LASE":
					aoi = wepArr;
					ioi = 3;
				break;
				case "EXP":
					aoi = upgArr;
					ioi = 0;
				break;
				case "SPD":
					aoi = upgArr;
					ioi = 1;
				break;
				case "REL":
					aoi = upgArr;
					ioi = 2;
				break;
				case "AMM":
					aoi = upgArr;
					ioi = 3;
				break;
			}
			
			cg.addMoney( -price);
			arm.acknowledge.gotoAndPlay(2);
			
			// if a weapon was selected with index ioi
			if (aoi == wepArr)
			{
				cg.turret.enableWeapon(weapon, slot);
				selArr[ioi].lock.visible = false;
				wepStatus[ioi] = true;
				wepCount++;
				
				arm.btn_purchase.visible = false;
				arm.tf_price.text = "Owned!";	
			}
			// if an upgrade was selected with index ioi
			else if (aoi == upgArr)
			{				
				upgLevel[ioi]++;			// level this upgrade up
				lvlArr[ioi].tf_lvl.text = "Lv." + upgLevel[ioi];
				arm.tf_title.text = arm.tf_title.text.substring(0, 3) + " Lv." + upgLevel[ioi];
				
				// show new price
				arm.tf_price.text = (upgLevel[ioi] < 9 ? "$" + upgCost[ioi][upgLevel[ioi]] : "MAX LVL");		
				arm.btn_purchase.visible = upgLevel[ioi] < 9;
				setUpgDesc(upgArr[ioi].name);	// update right side text
			}
			
			cg.turret.upgradeAll();
		}
	}
}