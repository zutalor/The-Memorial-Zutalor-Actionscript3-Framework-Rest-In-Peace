package com.zutalor.controllers.message 
{
	import com.zutalor.amfphp.Remoting;
	import com.zutalor.controllers.AbstractController;
	import com.zutalor.interfaces.IUiController;
	import com.zutalor.properties.ApplicationProperties;
		import com.zutalor.view.properties.ViewItemProperties;
	import com.zutalor.propertyManagers.ViewPropsManager;
	import com.zutalor.translate.Translate;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class MessageController extends AbstractController implements IUiController
	{
		private var _messageVO:MessageVO;
		public var emailTo:String;
				
		public function MessageController() 
		{
			_messageVO = new MessageVO();
		}
				
		override public function getValueObject(params:Object=null):*
		{
			return _messageVO;
		}
		
		public function create():void
		{	
			var vip:ViewItemProperties;
			var remoting:Remoting = new Remoting();
			
			vip = ViewPropsManager.gi().getViewItemPropsByName(controller.viewId, "emailTo");
			emailTo = Translate.tText(vip.tText);

			remoting.call("Email.send", null, null, onResult, onResult, emailTo, String(_messageVO.email), String(ApplicationProperties.gi().appName + ": " + _messageVO.name), String(_messageVO.message));
			
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