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
		
		public function ContainerIntro()
		{
			super();
			
			menu = new ContainerMenu();
			addChild(menu);
			
			menu.btn_level0.addEventListener(MouseEvent.CLICK, onLevel);
			menu.btn_level1.addEventListener(MouseEvent.CLICK, onLevel);
			menu.btn_level2.addEventListener(MouseEvent.CLICK, onLevel);
		}
		
		private function onLevel(e:MouseEvent):void
		{			
			switch (e.target)
			{
				case menu.btn_level0:
					lvl = 0;
				break;
				case menu.btn_level1:
					lvl = 1;
				break;
				case menu.btn_level2:
					lvl = 2;
				break;
			}
			
			menu.btn_level0.removeEventListener(MouseEvent.CLICK, onLevel);
			menu.btn_level1.removeEventListener(MouseEvent.CLICK, onLevel);
			menu.btn_level2.removeEventListener(MouseEvent.CLICK, onLevel);
			
			completed = true;
			
			// -- TODO have Engine utilize lvl
		}
	}
}
