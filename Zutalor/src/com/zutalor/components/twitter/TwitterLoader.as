package com.zutalor.twitter 
{
	import com.greensock.easing.Sine;
	import com.greensock.TweenMax;
	import com.gskinner.utils.IDisposable;
	import com.zutalor.containers.base.ContainerObject;
	import com.zutalor.application.ApplicationProperties;
	import com.zutalor.properties.Presets;
	import com.zutalor.utils.StrUtil;
	import com.zutalor.utils.DisplayObjectUtils;
	import com.zutalor.utils.MasterClock;
	import com.zutalor.utils.TimerRegistery;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.net.navigateToURL;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextField;
	
	/**
	 *
	 * 
	 * @author Geoff Pepos inspired from "The Burned Out Hippy" Code
	 * @version 1.0
	 * 
	 */
	
	public class TwitterLoader extends Sprite implements IDisposable
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
		public var loader:URLLoader;
		private var _onComplete:Function;
		private var _ap:ApplicationProperties;
		private var _pr:Presets;
		private var _proxyUrl:String;
		private var _url:String;

		private var _numTweets:int;	
		private var _refreshSecs:int;
		private var _tweetIndex:int;		
		private var _tweetWidth:int;
		private var _hPad:int;
		private var _vPad:int;
		private var _picOn:Boolean;
		private var _allowClicks:Boolean;
		private var _tweetsToShow:int;
		private var _stylesheet:String;
		private var _transitionTime:int;
		
		private var _tweets:Array;	
		public var status:String;
		private var _c:ContainerObject;

		public function TwitterLoader() 
		{			
			_tweets = [];
			_ap = ApplicationProperties.gi();
		}
		
		public function get numTweets():int
		{
			return _numTweets;
		}
		
		public function get tweets():Array
		{
			return _tweets;
		}	
				
		public function initialize(url:String, proxyUrl:String, stylesheet:String, tweetWidth:int, 
										hPad:int, vPad:int, options:String=null, onComplete:Function = null):void
		{		
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onSearchResult, false, 0, true);
			loader.addEventListener(ProgressEvent.PROGRESS, progressHandler, false, 0, true);
			loader.addEventListener(IOErrorEvent.IO_ERROR, IOError, false, 0, true);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError, false, 0, true);	
			_url = url;
			_c = new Container(url, tweetWidth, 800);
			addChild(_c);
			_proxyUrl = proxyUrl;
			_onComplete = onComplete;
			_stylesheet = stylesheet;
			_tweetWidth = tweetWidth;		
			_allowClicks = true;
			_hPad = hPad;
			_vPad = vPad;
			parseOptions(options);
			if (_refreshSecs)
				MasterClock.registerCallback(readTweets, true, _refreshSecs * 1000);
				
			readTweets();
		}
				
		public function readTweets():void
		{	
			if (_transitionTime && _c.numContainerChildren)
				TweenMax.to(_c, _transitionTime, { alpha:0, onComplete:_readTweets } );
			else
				_readTweets();
		}
		
		private function _readTweets():void
		{
			var urlReq:URLRequest;
			
			if (_c.numContainerChildren)
				_c.cleanup();
			
			if (_proxyUrl)	
				urlReq = new URLRequest(_proxyUrl + "/proxy.php?url=" + _url);
			else	
				urlReq = new URLRequest(_url);
				
			loader.load(urlReq);
			
		}
		
		public function dispose():void
		{
			MasterClock.unRegisterCallback(readTweets);
			loader.removeEventListener(Event.COMPLETE, onSearchResult);
			loader.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, IOError);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);					
			//TODO
		}
		
		// PRIVATE METHODS
		
		private function parseOptions(options:String):void
		{
			var opt:Array = [];
			
			opt = options.split(",");
			
			for (var i:int = 0; i < opt.length; i++)
				switch (i)
				{
					case 0 :
						_picOn = StrUtil.toBoolean(opt[i]);
						break;
					case 1 :
						_allowClicks = StrUtil.toBoolean(opt[i]);
						break;
					case 2 :
						_tweetsToShow = int(opt[i]);
						break;
					case 3 :
						_refreshSecs = int(opt[i]);
						break;	
					case 4 :
						_transitionTime = int(opt[i]);
				}
		}		
		
		private function onSecurityError(e:SecurityErrorEvent):void
		{
			// do nothing now
		}
				
		private function onSearchResult(e:Event):void 
		{
			var twitterXml:XML = new XML(e.target.data)
			var tweetList:XMLList = twitterXml.children();
			var testStr:String;
			var curTweet:Tweet;	
			
			if (_transitionTime)
				_c.alpha = 0;

			for (var i:int = 0; i < _tweets.length; i++)
			{
				if (_tweets[i])
					resetTweet(_tweets[i]);
			}
			testStr = String(e.target.data);
			//trace (tweetList);
			_tweetIndex = 0;
			loader.close();
			if (testStr.indexOf("Bad Request") == -1)
			{
				_numTweets = 0;
				for (var d:int = 0; d < tweetList.length(); d++)
					if (tweetList[d].name().localName == "entry")
						_numTweets++ // total hack;
				
				_tweetIndex = 0;
				for (var x:int = 0; x < tweetList.length(); x++) 
				{
					if (tweetList[x].name().localName == "entry")
					{
						var thisTweetXML:XML = tweetList[x];
						
						if (!_tweets[_tweetIndex])
							_tweets[_tweetIndex] = new Tweet();
						
						curTweet = _tweets[_tweetIndex];	
						TweetFormatter.format(curTweet, _proxyUrl, thisTweetXML, _stylesheet, _tweetWidth, _hPad, _picOn, _allowClicks);
						if (curTweet.imageUrl && _allowClicks)
							curTweet.imageSprite.addEventListener(MouseEvent.CLICK, onPicClick, false, 0, true);						
						
						_c.push(curTweet);
						_tweetIndex++;
						if (_tweetsToShow)
							if (_tweetIndex == _tweetsToShow)
								break;
				   }
				}
				_c.autoArrangeContainerChildren( { padding:_vPad, arrange:"vertical" } );
				
				if (_transitionTime)
					TweenMax.to(_c, _transitionTime, { alpha:1 } );
					
				if (_onComplete != null)
					_onComplete(this);
			}
		}
		
		private function onPicClick(e:Event):void
		{
			var request:URLRequest = new URLRequest(e.target.parent.parent.authorUri);
			try 
			{
				navigateToURL(request, '_blank');	
			}
			catch (e:Error)
			{
				trace ("Error visiting Twitter page");
			}
		}		
		
		private function resetTweet(tweet:Tweet):void
		{
				tweet.imageUrl = "";
				tweet.content.htmlText = "";
				tweet.date.htmlText = "";
				if (_allowClicks)
					tweet.imageSprite.removeEventListener(MouseEvent.CLICK, onPicClick);				
				DisplayObjectUtils.removeAllChildren(tweet.imageSprite);
				tweet.authorUri = "";
				tweet.author.htmlText = "";
		}
		
		private function progressHandler(event:ProgressEvent):void 
		{
			var perc:int = (event.bytesLoaded/event.bytesTotal)*100;
			status = "<h1>Loading...please wait</h1><p>" + perc + "%</p>";
		}
		
		private function IOError(e:Event):void 
		{
			trace("IO error");
			status = "<h1>Sorry!</h1><p>There appears to be a problem with Twitter at the moment.</p>";
		}

		private function SecurityError(e:Event):void 
		{
			trace("security error");
			status = "security error";
		}	
	}
}