package com.plagro.tweets
{
	import com.plagro.processors.FindURL;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.net.navigateToURL;
	
	/**
	 * Tweeter allows you to display a tweet from a single Twitter account with ease
	 * 
	 * @author The Burned Out Hippy
	 * @example http://www.burnedouthippy.com
	 * @version 1.0
	 * 
	 */
	
	public class Tweeter extends Sprite
	{
		/**
		 * Public variables
		 * 
		 * @param	tweetField		The main text field (allows for styling outside of the class)
		 * @param	loader			The URLLoader used to bring the tweet from the proxy (allows for
		 * 							event listeners outside of the class)	
		 * 
		 */ 
		public var tweetField:TextField;
		public var loader:URLLoader = new URLLoader();
		private var _onComplete:Function;
		
		/**
		 * Private variables
		 * 
		 * @param	_twitterXML		Where the text is initially stored
		 * @param	_twitterUser	The default Twitter username
		 * @param	_titleArr		Array used to separate the dates from each tweet (so class can be 
		 * 							expanded to allow for multiple tweets at a later date)
		 * @param	_contentArr		Array used to separate the main body from each tweet
		 * @param	_proxyURL		Variable to store the URL of the Twitter proxy PHP file
		 * @param	_userPic		Variable to store the URL of the user's profile picture
		 * @param	_pictureOn		Boolean variable that turns the profile pic on and off (default:on)
		 * @param	_img			Container sprite for the downloaded profile image	
		 * 
		 */ 
		private var _twitterXML:XML;
		private var _twitterUser:String = "burnedouthippy";
		private var _titleArr:Array = new Array();
		private var _contentArr:Array = new Array();
		private var _proxyURL:String;
		private var _userPic:String;
		private var _pictureOn:Boolean = true;
		private var _img:Sprite;
		/**
		 * Constructor
		 * 
		 */ 	
		public function Tweeter():void
		{			
			tweetField = new TextField();	
			tweetField.htmlText = "";
			tweetField.wordWrap = true;
			tweetField.width = 300;
			tweetField.autoSize = TextFieldAutoSize.LEFT;
			tweetField.multiline = true;
			tweetField.htmlText = "<h1>Loading...please wait</h1>";
			addChild(tweetField);
		}
		
		public function getTweet(onComplete:Function):void
		{		
			_onComplete = onComplete;
			loadTweet();
		}
		
		public function set user(newTweeter:String):void
		{
			_twitterUser = newTweeter;
		}
		
		public function set proxy(newProxy:String):void
		{
			_proxyURL = newProxy;
		}
		
		public function set picture(picOn:Boolean):void
		{
			_pictureOn = picOn;
		}
		
		private function loadTweet():void
		{
			var urlReq:URLRequest = new URLRequest(_proxyURL + "/proxy.php?url=http://twitter.com/statuses/user_timeline/"+_twitterUser+".xml?count=1");
			
			loader.addEventListener(Event.COMPLETE, SuccessFunc);
			loader.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, IOError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, SecurityError);
			loader.load(urlReq);
		}
		
		private function SuccessFunc(e:Event):void
		{
			var testStr:String;
			
			testStr = String(e.target.data);
			tweetField.htmlText = "";
			
			if (testStr.indexOf("Bad Request") == -1)
			{	
				if (e.target.data) { _twitterXML = new XML(e.target.data); }
		
				var _tweetList:XMLList = _twitterXML.children();
				
				/* 
				for loop repeats action so if you change the number of tweet requests it will pull out
				the bits you want from all of the tweets;
				*/
				for (var x:int = 0; x < _tweetList.length(); x++) {
					if (_tweetList[x].name().localName == "status") 
					{
						/* split each tweets XML into it's individual nodes (trace nodes for all node titles) */
						var thisTweet:XML = _tweetList[x];
						var nodes:XMLList = thisTweet.children();
						
						/* examine each node */	
						for (var y:int = 0; y < nodes.length(); y++)
						{
							/* look for particular nodes */	
							if (nodes[y].name().localName == "created_at") 
							{
								tweetField.htmlText = "<h1>" + nodes[y].substr(0,19) + "</h1>";
							} 
							else if (nodes[y].name().localName == "text")
							{
								var linkFinder:FindURL = new FindURL(nodes[y]);
								var newString:String = linkFinder.Process();
								tweetField.htmlText += "<p>" + newString + "</p>";
							}
							else if (nodes[y].name().localName == "user")
							{
								if(_pictureOn)
								{
									_img = new Sprite();
									addChild(_img);
									_userPic = nodes[y].children()[5];
									displayProfilePic();
								}
								
							}
						} //end for
						
					} // end if
				} // end for	
			}
			_onComplete();

		}
		
		private function progressHandler(event:ProgressEvent):void 
		{
			var perc:int = (event.bytesLoaded/event.bytesTotal)*100;
			tweetField.htmlText = "<h1>Loading...please wait</h1><p>" + perc + "%</p>";
		}	
		private function IOError(e:Event):void 
		{
			trace("IO error");
			tweetField.htmlText = "<h1>Sorry!</h1><p>There appears to be a problem with Twitter at the moment</p>";
		}

		private function SecurityError(e:Event):void 
		{
			trace("security error");
		}

		private function displayProfilePic():void
		{
			/* The default Twitter user profile picture size is 48px by 48px) hence the numbers below */
			var picLoader:Loader = new Loader();
			picLoader.load(new URLRequest(_userPic));
			_img.addChild(picLoader);
			_img.x = tweetField.x - 50;
			_img.y = tweetField.height/2 - 24;
			
			_img.buttonMode = true;
			_img.addEventListener(MouseEvent.CLICK, onPicClick);
		}
		
		private function onPicClick(e:Event):void
		{
			/* The following is the long winded replacement for AS2's getURL() */
			var url:String = "http://www.twitter.com/"+_twitterUser;
			var request:URLRequest = new URLRequest(url);
			try 
			{
				navigateToURL(request, '_blank');	
			}
			catch (e:Error)
			{
				trace ("Error visiting Twitter page");
			}

		}
	
	}
}