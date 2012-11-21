package com.zutalor.view.controller 
{
	import com.zutalor.view.controller.ViewController;
	import com.zutalor.utils.gDictionary;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ViewControllerRegistry
	{
		private static var _controllerDictionary:gDictionary = new gDictionary();
		
		public static function getController(controllerId:String=null):ViewController
		{
			var requestedController:ViewController;
			
			requestedController = _controllerDictionary.getByKey(controllerId);
			if (requestedController)
				return requestedController;
			else
				return null;
		}
		
		public static function registerController(id:String, controller:ViewController):void
		{
			_controllerDictionary.insert(id, controller);
		}	
		
		public static function unregisterController(id:String):void
		{
			_controllerDictionary.deleteByKey(id);
		}				
	}
}