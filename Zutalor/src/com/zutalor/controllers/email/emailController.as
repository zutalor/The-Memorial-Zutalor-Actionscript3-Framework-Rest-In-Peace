package com.zutalor.controllers.email 
{
	import com.zutalor.amfphp.Remoting;

	import com.zutalor.interfaces.IUiController;
	import com.zutalor.properties.ApplicationProperties;
	import com.zutalor.view.properties.ViewItemProperties;
	import com.zutalor.propertyManagers.ViewPropsManager;
	import com.zutalor.translate.Translate;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class EmailController extends UiControllerBase implements IUiController
	{
		private var _emailVO:EmailVO;
		public var emailTo:String;
				
		public function MessageController() 
		{
			_emailVO = new MessageVO();
		}
				
		override public function getValueObject(params:Object=null):*
		{
			return _emailVO;
		}
		
		public function send():void
		{	
			var vip:ViewItemProperties;
			var remoting:Remoting = new Remoting();
			
			vip = ViewPropsManager.gi().getViewItemPropsByName(controller.viewId, "emailTo");
			emailTo = Translate.tText(vip.tText);

			remoting.call("Email.send", null, null, onResult, onResult, emailTo, String(_emailVO.email), String(ApplicationProperties.gi().appName + ": " + _emailVO.name), String(_emailVO.message));
			
			function onResult(responds:Object):void
			{
				if (responds == true)
				{
					controller.vmg.setAllInitialValues();
					controller.onModelChange();
				}
				else
					controller.onModelError();
			}
		}
	}
}