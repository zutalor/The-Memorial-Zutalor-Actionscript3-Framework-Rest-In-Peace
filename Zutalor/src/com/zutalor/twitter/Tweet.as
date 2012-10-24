package com.zutalor.twitter  
{
	import flash.display.Sprite;
	import flash.text.TextField;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Tweet extends Sprite
	{
		public var date:TextField;
		public var content:TextField;
		public var author:TextField;
		public var imageSprite:Sprite;
		public var authorUri:String;
		public var imageUrl:String;
		
		public function Tweet() 
		{
			date = new TextField();
			content = new TextField();
			author = new TextField();
			imageSprite = new Sprite();
			addChild(author);
			addChild(imageSprite);
			addChild(date);
			addChild(content);
		}
		
	}

}