package com.zutalor.controllers.wordpress
{
	import com.zutalor.amfphp.Remoting;
	import com.zutalor.models.wordpress.BlogModel;
	import com.zutalor.utils.MasterClock;
	import com.zutalor.utils.TimerRegistery;
	import flash.events.Event;
	import flashpress.vo.WpMetaVO;
	import flashpress.vo.WpPostCountVO;
	import flashpress.vo.WpPostVO;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class PostController extends BlogController
	{	
		private static const NUM_POSTS_TO_READ:int = 6;
		
		private var _postIdList:Array;
		private var _currentPostIndex:int;
		private var _numPosts:int;
		private var _postIsLoaded:Boolean;
		private var savedVO:*;
		
		public function PostController() 
		{
		}
								
		public function loadPostByTitle(catagory:String):void
		{
			controller.setStatusMessage(controller.readingMessage);		
			_currentPostIndex = _blogPostDetailsVO.post_titles.indexOf(_blogPostDetailsVO.post_selected) + 1;
			read(catagory);
		}
		
		public function reset():void
		{
			savedVO = null;
			_numPosts = 0;
			_currentPostIndex = 1;
		}
		
		public function read(catagory:String=null):void
		{	
			if (!_numPosts)
				countPosts(catagory, read);
			else
				_read(catagory);
		}
		
		private function _read(catagory:String=null):void
		{
			var params:String;
			var voIndex:int;

			_numCallsToComplete = 0;
			_completedCalls = [];			
			
			_postIsLoaded = false;	

			controller.setItemVisibility("comment-button", false);
			controller.setItemVisibility("next-button", false);
			controller.setItemVisibility("prev-button", false);

			_numCallsToComplete++;
			getBlogRoll();
		
			if (!savedVO || _numPosts % NUM_POSTS_TO_READ > NUM_POSTS_TO_READ)
			{
				voIndex = 0;
				params = "numberposts=" + NUM_POSTS_TO_READ + "6&offset=" + String(_numPosts - _currentPostIndex);
				if (catagory)
					params += "&category_name=" + catagory;
				
				var remoting:Remoting = new Remoting();
				remoting.call("WpMethodsService.getPosts", "flashpress.vo.WpPostVO", WpPostVO, onResult, onError, params );									
			}
			else
			{
				voIndex = _currentPostIndex - 1;
				onResult(savedVO);
			}
			function onResult(pVO:Object):void
			{

				_wpPostVO = WpPostVO(pVO[voIndex]);
				savedVO = pVO;
				if (pVO.length)
				{	
					_blogPostDetailsVO.post_selected = pVO[voIndex].post_title;
					formatPost();
					MasterClock.registerCallback(checkLoadStatus, true, 100);					
					_blogPostDetailsVO.post_titles = [];
					for (var i:int = 0; i < NUM_POSTS_TO_READ; i++)
					{
						if (pVO[i])
						{
							_blogPostDetailsVO.post_titles[i] = pVO[i].post_title;
						}
						else
							break;
					}
					
					_numCallsToComplete++;					
					getTags();
					
					if (_wpPostVO.comment_count)
					{
						_numCallsToComplete++;
						getComments();
					}
				}
				else
				{
					onModelError(pVO);
				}
			}
			
			function onError(result:Object):void
			{
				onModelError(result);
			}
		}
		
		private function checkLoadStatus():void
		{
			if (_completedCalls.length == _numCallsToComplete)
			{
				MasterClock.unRegisterCallback(checkLoadStatus);
				
				onModelChange();
			}
		}
			
		public function next(category:String=null):void
		{
			
			if (_currentPostIndex < _numPosts) // 1 based index 
			{
				_currentPostIndex++;
				read(category);
			}
		}
		
		public function previous(category:String=null):void
		{
			if (_currentPostIndex > 1) // 1 based index
			{
				_currentPostIndex--;
				read(category);
			}
		}
		
		public function last(category:String=null):void
		{
			countPosts(category, _last);
		}
		
		private function _last(category:String=null):void
		{
			_currentPostIndex = _numPosts;
			read(category);
		}
		
		public function first(category:String=null):void
		{
			_currentPostIndex = 1;
			read(category);
		}
		
		override public function onModelChange(responds:*=null):void
		{
			super.onModelChange(responds);
			_postIsLoaded = true;
			setButtonVisibility();
		}
		
		override public function onModelError(responds:*=null):void
		{
			super.onModelError(responds);
			_postIsLoaded = false;
			setButtonVisibility();
		}
						
		private function countPosts(category:String, onComplete:Function):void
		{
			var remoting:Remoting = new Remoting();
			
			if (!category)
				remoting.call("WpMethodsService.countPosts", "flashpress.vo.WpPostCountVO", WpPostCountVO, onResult, onError);
			else
				remoting.call("WpMethodsService.countPostsInCategories", "flashpress.vo.WpPostCountVO", WpPostCountVO, onResult, onError, category);
			
			function onResult(responds:Object):void
			{
				_wpPostCountVO = WpPostCountVO(responds);
				_numPosts = _wpPostCountVO.publish;
				onComplete(category);
			}
			function onError(responds:*):void
			{
				onModelError(responds);
			}
		}
				
		private function setButtonVisibility():void
		{	
			if (_currentPostIndex == _numPosts || !_postIsLoaded || !_currentPostIndex)
				controller.setItemVisibility("next-button", false);
			else	
				controller.setItemVisibility("next-button", true);

			if (_currentPostIndex == 1 || !_postIsLoaded || !_currentPostIndex)
				controller.setItemVisibility("prev-button", false);
			else	
				controller.setItemVisibility("prev-button", true);
				
			if (!_postIsLoaded || _wpPostVO.comment_status == "closed")
				controller.setItemVisibility("comment-button", false);
			else
				controller.setItemVisibility("comment-button", true);
		}		
	}
}