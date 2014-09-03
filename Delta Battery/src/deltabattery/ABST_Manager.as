package deltabattery 
{
	import cobaltric.ContainerGame;
	import flash.display.MovieClip;
	/**
	 * ...
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