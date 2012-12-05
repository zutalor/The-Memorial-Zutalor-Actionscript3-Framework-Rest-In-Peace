package com.zutalor.controllers.wordpress
{
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class BlogPostDetailsVO
	{
		public var post_num_comments:int;
		public var post_selected:String;
		public var post_content:String;
		public var tag_selected:String;
		public var link_selected:String;
		public var post_titles:Array;
		public var post_tags:Array;
		public var blog_roll_names:Array;
		public var blog_roll_urls:Array;
		public var vid_url:String;
		
		public function BlogPostDetailsVO() 
		{
			post_titles = [];
			post_tags = [];
			blog_roll_names = [];
			blog_roll_urls = [];
		}
	}
}