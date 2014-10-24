package deltabattery 
{
	import cobaltric.ContainerGame;
	import deltabattery.weapons.ABST_Weapon;
	import deltabattery.weapons.Weapon_HES;
	import deltabattery.weapons.Weapon_RAAM;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;

	/**
	 * ...
	 * @author Alexander Huynh
	 */
	public class Armory 
	{
		private var cg:ContainerGame;
		private var arm:MovieClip;
		
		private var wepArr:Array;	// list of weapon buttons
		private var selArr:Array;	// list of 'selected' MC's on weapon buttons
		private var upgArr:Array;	// list of upgrade buttons
		private var lvlArr:Array;	// list of upgrade levels
		
		private var wepCost:Array = [500, 500, 2100, 3000];
								  // fast  big   flak  laser
								  // null if purchased
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
			arm.tf_desc.text = "Click an upgrade to view information.";
			arm.btn_purchase.visible = false;
			arm.ammoGroup.visible = false;
			arm.tf_price.text = "";
			
			wepArr = [arm.btn_arm_fast, arm.btn_arm_big,
					  arm.btn_arm_flak, arm.btn_arm_laser];
			selArr = [];
			
			upgArr = [arm.btn_arm_explosion, arm.btn_arm_speed,
					  arm.btn_arm_reload];
			lvlArr = [arm.lvl_explosion, arm.lvl_speed,
					  arm.lvl_reload];
					  
			var select:MovieClip;
			var i:int;
			for (i = 0; i < wepArr.length; i++)
			{
				wepArr[i].addEventListener(MouseEvent.CLICK, onWeapon);
				select = new Selected();
				select.x = wepArr[i].x; select.y = wepArr[i].y;
				select.buttonMode = select.mouseChildren = false;
				selArr.push(select);
				//select.lock.visible = false;
				arm.addChild(select);
			}
			for (i = 0; i < upgArr.length; i++)
			{
				upgArr[i].addEventListener(MouseEvent.CLICK, onUpgrade);
				lvlArr[i].buttonMode = lvlArr[i].mouseChildren = false;
			}
			
			arm.btn_purchase.addEventListener(MouseEvent.CLICK, onPurchase);
		}
		
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
			arm.btn_purchase.visible = wepCost[ind];
			arm.ammoGroup.visible = !wepCost[ind];
			arm.tf_price.text = wepCost[ind] ? "$" + wepCost[ind] : "";
			boi = arm.tf_title.text;
			for (var i:int = 0; i < selArr.length; i++)
				selArr[i].gotoAndStop("unselected");
			selArr[ind].gotoAndPlay("selected");
		}
		
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
			
			if (aoi == wepArr)
			{
				cg.turret.enableWeapon(weapon, slot);
				selArr[ioi].lock.visible = false;
			}
				
			arm.btn_purchase.visible = false;
			arm.ammoGroup.visible = true;
			arm.tf_price.text = "";	
		}
	}
}