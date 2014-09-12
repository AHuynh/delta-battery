package deltabattery.managers
{
	import cobaltric.ContainerGame;
	import deltabattery.ABST_Base;
	import flash.display.MovieClip;
	
	/**	An abstract Manager
	 * 
	 * 	A Manager controls a specific object, keeps track of
	 * 	them in objArr, and is steppable by ContainerGame.
	 * 
	 * @author Alexander Huynh
	 */
	public class ABST_Manager extends ABST_Base
	{
		public var cg:ContainerGame;
		public var objArr:Array;
		
		public function ABST_Manager(_cg:ContainerGame) 
		{
			cg = _cg;
			objArr = [];
		}
		
		public function step():void
		{
			// -- override this function
		}
		
		public function hasObjects():Boolean
		{
			return objArr.length > 0;
		}
	}

}