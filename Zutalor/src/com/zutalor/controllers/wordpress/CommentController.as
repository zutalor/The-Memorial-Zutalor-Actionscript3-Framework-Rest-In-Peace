package com.zutalor.controllers.wordpress
{
	import com.zutalor.amfphp.Remoting;
	import com.zutalor.constants.ModelMethods;
	import com.zutalor.controllers.AbstractController;
	import com.zutalor.interfaces.IUiController;
	import com.zutalor.plugin.Plugins;
	import flashpress.vo.WpCommentVO;
	import flashpress.vo.WpTermVO;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class CommentController extends AbstractController implements IUiController
	{
		private var _wpCommentVO:WpCommentVO;
		private var _wpTermVO:WpTermVO;	
		private var _remoting:Remoting;
		
		public function CommentController() 
		{
			_wpCommentVO = new WpCommentVO;
		}
				
		override public function getValueObject(params:Object = null ):*
		{
			return _wpCommentVO;
		}
				
		public function create():void
		{
			var postId:int;
			
			postId = Plugins.callMethod("postModel", ModelMethods.GET_VALUE_OBJECT, { voName:"wpPostVO" } )["ID"];			
			_remoting = new Remoting();
			_remoting.call("WpMethodsService.newComment", "flashpress.vo.WpCommentVO", WpCommentVO, onModelChange, onModelError, int(postId), 
																String(_wpCommentVO.comment_author), String(_wpCommentVO.comment_author_email), 
																String(_wpCommentVO.comment_author_url), String(_wpCommentVO.comment_content));
		}
	}
}