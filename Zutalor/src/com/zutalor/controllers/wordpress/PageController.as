package com.zutalor.controllers.wordpress
{
	import com.zutalor.amfphp.Remoting;
	import com.zutalor.models.wordpress.BlogModel;
	import flashpress.vo.WpPostVO;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class PageController extends BlogController
	{		
		public function getPageByTitle(title:String=null):void
		{					
			if (title == null)
				ShowError.fail(this,"PageModel.getPageByTitle: title is empty");
			
			var remoting:Remoting = new Remoting();
			controller.setStatusMessage(controller.readingMessage);
			remoting.call("WpMethodsService.getPageByTitle", "flashpress.vo.WpPostVO", WpPostVO, onResult, onModelError, title, "");
				
			function onResult(pVO:Object):void
			{
				if (!(pVO is Array))
				{					
					_wpPostVO = WpPostVO(pVO);
					formatPost();
					onModelChange();
				}
				else
					onModelError();
			}
		}
	}
}