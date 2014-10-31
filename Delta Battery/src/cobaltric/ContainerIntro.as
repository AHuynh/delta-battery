package cobaltric
{
	import flash.events.MouseEvent;
	/**	Main menu screen
	 * 	@author Alexander Huynh
	 */
	public class ContainerIntro extends ABST_Container
	{
		public var menu:ContainerMenu;
		public var lvl:uint;
		private var eng:Engine;
		
		public function ContainerIntro(_eng:Engine)
		{
			super();
			eng = _eng;
			
			menu = new ContainerMenu();
			addChild(menu);
			
			menu.menu_credits.visible = false;
			menu.menu_main.btn_level0.addEventListener(MouseEvent.CLICK, onLevel);
			menu.menu_main.btn_level1.addEventListener(MouseEvent.CLICK, onLevel);
			menu.menu_main.btn_level2.addEventListener(MouseEvent.CLICK, onLevel);
		}
		
		private function onLevel(e:MouseEvent):void
		{			
			switch (e.target)
			{
				case menu.menu_main.btn_level0:
					lvl = 1;
				break;
				case menu.menu_main.btn_level1:
					lvl = 4;
				break;
				case menu.menu_main.btn_level2:
					lvl = 7;
				break;
			}

			menu.menu_main.btn_level0.removeEventListener(MouseEvent.CLICK, onLevel);
			menu.menu_main.btn_level1.removeEventListener(MouseEvent.CLICK, onLevel);
			menu.menu_main.btn_level2.removeEventListener(MouseEvent.CLICK, onLevel);
			
			menu.destroy();
			eng.startWave = lvl;
			completed = true;
		}
	}
}
