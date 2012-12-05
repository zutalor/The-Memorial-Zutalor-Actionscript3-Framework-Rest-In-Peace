package com.zutalor.controllers.wordpress
{
	import com.zutalor.amfphp.Remoting;
	import com.zutalor.controllers.base.UiControllerBase;
	import com.zutalor.interfaces.IUiController;
	import com.zutalor.loaders.URL;
	import flashpress.vo.WpBlogRollVO;
	import flashpress.vo.WpCommentVO;
	import flashpress.vo.WpPostCountVO;
	import flashpress.vo.WpPostVO;
	import flashpress.vo.WpTermVO;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class BlogController extends UiControllerBase implements IUiController
	{
		protected var _wpPostVO:WpPostVO;
		protected var _wpPostCountVO:WpPostCountVO;
		protected var _wpCommentVO:WpCommentVO;
		protected var _wpTermVO:WpTermVO;
		protected var _wpBlogRollVO:WpBlogRollVO;
		protected var _blogPostDetailsVO:BlogPostDetailsVO;
		
		protected var _completedCalls:Array;
		protected var _numCallsToComplete:int;
				
		public function BlogController() 
		{	
			_blogPostDetailsVO = new BlogPostDetailsVO();	
		}
		
		override public function getValueObject(params:Object = null):*
		{
			if (params)
			{
				switch (params["voName"])
				{
					case "wpPostVO" :
						return _wpPostVO;
						break;
					case "blogPostDetailsVO" :
						return _blogPostDetailsVO;
						break;
				}
			}
			return null;
		}
		
		public function followLink():void
		{
			var urlIndx:int = _blogPostDetailsVO.blog_roll_names.indexOf(_blogPostDetailsVO.link_selected);
			if (urlIndx != -1)
				URL.open(_blogPostDetailsVO.blog_roll_urls[urlIndx]);
		}
					
		protected function formatPost():void
		{
			var s:String = "";
			var reg:RegExp = new RegExp("\\[hdplay.*\]", "ms");
			var urlr:RegExp = new RegExp("http.*.f4v");
			
			var vidUrl:String
						
			s = _wpPostVO.post_content;
			s = s.split("<a href").join('<span class="url"><a href');
			s = s.split("</a>").join("</a></span>");
			s = s.split("<blockquote>").join('<span class="blockquote">');
			s = s.split("</blockquote>").join('</span>');
			s = s.split("<strong>").join('<span class="strong">');
			s = s.split("</strong>").join('</span>');
			s = s.split("<code>").join('<span class="code">');
			s = s.split("</code>").join('</span>');
			s = s.split("<em>").join('<span class="em">');
			s = s.split("</em>").join('</span>');
			s = s.split("\n").join('<P></P>');
			s = "<P>" + s + "</P>";
			
			vidUrl = urlr.exec(reg.exec(s));
			
			if (vidUrl)
				s = s.replace(reg, '');
				
			_blogPostDetailsVO.vid_url = vidUrl;	
				
			_blogPostDetailsVO.post_content = s;
		}								

		protected function getComments():void
		{
			var remoting:Remoting = new Remoting();
			remoting.call("WpMethodsService.getComments", "flashpress.vo.WPCommentVO", WpCommentVO, onResult, onError, "status=approve&post_id=" + _wpPostVO.ID );

			function onResult(responds:*):void
			{
				_blogPostDetailsVO.post_content += '<p></p><p class="comment_header">COMMENTS:</p>'
				for (var i:int = 0; i < responds.length; i++)
				{
					_wpCommentVO = responds[i];
					_blogPostDetailsVO.post_content += "<p>"
					_blogPostDetailsVO.post_content += '<span class="comment_date">' + _wpCommentVO.comment_date + "</span>";
					_blogPostDetailsVO.post_content += '<span class="comment_author"> by ' + _wpCommentVO.comment_author + "</span>";
					_blogPostDetailsVO.post_content += "</p>";					
					_blogPostDetailsVO.post_content += '<p class="comment_content">' + _wpCommentVO.comment_content + "</p><p></p>";
				}
				remoting = null;
				_completedCalls.push("comments");
			}
			function onError(responds:*):void
			{
				logError(responds);
				remoting = null;
				_completedCalls.push("comments");
			}
		}		

		protected function getTags():void
		{
			var remoting:Remoting = new Remoting();
			remoting.call("WpMethodsService.getTagsByPostId","flashpress.vo.WPTermVO", WpTermVO, onResult, onError, _wpPostVO.ID);	
			
			function onResult(responds:*):void
			{
				_blogPostDetailsVO.post_tags = [];
				for (var i:int = 0; i < responds.length; i++)
				{
					_blogPostDetailsVO.post_tags[i] = responds[i].name;
				}
				remoting = null;
				_completedCalls.push("tags");
			}
			function onError(responds:*):void
			{
				logError(responds);
				remoting = null;
				_completedCalls.push("tags");
			}
		}
		
		protected function getBlogRoll():void
		{	
			var remoting:Remoting = new Remoting();
			remoting.call("WpMethodsService.getBookmarks", "flashpress.vo.WpBlogRollVO", WpBlogRollVO, onResult, onError, "");
			
			function onResult(responds:*):void
			{
				_blogPostDetailsVO.blog_roll_urls = [];
				_blogPostDetailsVO.blog_roll_names = [];
				for (var i:int = 0; i < responds.length; i++)
				{
					_blogPostDetailsVO.blog_roll_urls[i] = responds[i].link_url;
					_blogPostDetailsVO.blog_roll_names[i] = responds[i].link_name;
				}
				remoting = null;
				_completedCalls.push("blogroll");
			}
			function onError(responds:*):void
			{
				remoting = null;
				_completedCalls.push("blogroll");
				logError(responds);
			}
		}		
	}
}