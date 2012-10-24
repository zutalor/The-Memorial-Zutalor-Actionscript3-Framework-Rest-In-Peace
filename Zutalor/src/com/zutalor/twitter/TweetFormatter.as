package com.zutalor.twitter
{
	import com.zutalor.text.TextUtil;
	import com.zutalor.utils.StrUtil;
	import com.zutalor.ui.DrawGraphics;
	import com.plagro.processors.FindURL;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.system.LoaderContext;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
		 
	public class TweetFormatter
	{
		public static var ATOM:Namespace = new Namespace( "http://www.w3.org/2005/Atom" );
		public static var _proxyUrl:String;
		public static var _picLoader:Loader;
		
		public static function format(curTweet:Tweet, proxyUrl:String, thisTweetXML:XML, stylesheet:String, 
												textWidth:int, hPad:int, picOn:Boolean=true, allowClicks:Boolean = true):void
		{
			var content:String;
			var linkFinder:FindURL;
			
			linkFinder = new FindURL(thisTweetXML.ATOM::content);
			content = linkFinder.Process();
			
			if (!allowClicks)
			{
				content = TextUtil.stripLinks(content);
			}
			
			_proxyUrl = proxyUrl;
			curTweet.authorUri = thisTweetXML.ATOM::author.ATOM::uri;
			curTweet.imageUrl = thisTweetXML.ATOM::link[1].@href;
			
			TextUtil.applyStylesheet(curTweet.author, stylesheet, textWidth);
			
			/*
			if (allowClicks)
			{
				curTweet.author.htmlText = 
					'"' + "<a href=" + '"' + curTweet.authorUri + '"' + 
							"><tweetHeader>" + thisTweetXML.ATOM::author.ATOM::name + "</tweetHeader>" + "</a>";						
			}
			else
			{
				curTweet.author.htmlText = 
					'"' + curTweet.authorUri + '"' + 
							"><tweetHeader>" + thisTweetXML.ATOM::author.ATOM::name + "</tweetHeader>";						
				
			}
			
			*/
			curTweet.author.y = 3;
			
			TextUtil.applyStylesheet(curTweet.date, stylesheet, textWidth);									
			curTweet.date.htmlText = "<tweetDate>" + thisTweetXML.ATOM::published.substr(0,10) + " " + thisTweetXML.ATOM::published.substr(11, 8)+ " UTC</tweetDate>";

			
			TextUtil.applyStylesheet(curTweet.content, stylesheet, textWidth);
			curTweet.content.htmlText += "<tweetText>" + content + "</tweetText>";
			
			curTweet.date.y = curTweet.author.y + curTweet.author.height;
			curTweet.content.y = curTweet.date.y + curTweet.date.height;
			
			if (picOn)
			{
				displayProfilePic(curTweet);
				curTweet.date.x = curTweet.content.x = curTweet.author.x = 60;
				curTweet.imageSprite.y = 10;
				curTweet.imageSprite.x = 5;
				if (allowClicks)
					curTweet.imageSprite.buttonMode = true;
			}
			
			if (hPad)
				curTweet.x = hPad;
		}

		private static function displayProfilePic(tweet:Tweet):void
		{
			/* The default Twitter user profile picture size is 48px by 48px) hence the numbers below */
			var context:LoaderContext = new LoaderContext();
			var urlRequest:URLRequest = new URLRequest();
			//urlRequest.method = URLRequestMethod.POST;
			context.checkPolicyFile = true;
			_picLoader = new Loader();

			if (_proxyUrl)
				urlRequest.url = _proxyUrl + "/proxy.php?url=" + tweet.imageUrl;
			else	
				urlRequest.url = tweet.imageUrl;
				
			_picLoader.load(urlRequest, context);
			_picLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onPicLoaded, false, 0, true);
			tweet.imageSprite.addChild(_picLoader);
		}
		
		private static function onPicLoaded(e:Event):void
		{
			var bit:Bitmap = e.target.content;
			e.target.removeEventListener(Event.COMPLETE, onPicLoaded);
			if (bit != null)
			{
				bit.width = 48;
				bit.height = 48;
				bit.smoothing = true;
			}
		}		
	}
}