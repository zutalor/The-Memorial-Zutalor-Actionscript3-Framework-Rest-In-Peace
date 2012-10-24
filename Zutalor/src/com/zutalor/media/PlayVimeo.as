package  
{
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class PlayVimeo 
	{
		
		public function PlayVimeo() 
		{
			
		}
		
	}
	
}

import flash.system.Security;
import flash.net.URLRequest;
import flash.display.Loader;
import flash.events.Event;
import flash.events.ProgressEvent;

var moogaloop:Sprite = new Sprite(); // the video player
var player_width:int=800;
var player_height:int=600;
var clip_id:int = 3257040;

function startLoad():void
{
	Security.allowDomain("bitcast.vimeo.com");	
	var v_loader:Loader = new Loader();
	var v_request = new URLRequest("http://bitcast.vimeo.com/vimeo/swf/moogaloop.swf?clip_id=" + clip_id + "&server=vimeo.com" + "&width=" + player_width + "&height=" + player_height + "&show_title=0&show_byline=0&show_portrait=0&color=ffffff&fullscreen=1");
	v_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onCompleteHandler, false, 0, true);
	v_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgressHandler, false, 0, true);
	v_loader.load(v_request);
}

function onCompleteHandler(e:Event):void
{
	// Position the player where you want it
	moogaloop.x = 5;
	moogaloop.y = 10;
	moogaloop.addChild(e.currentTarget.content);
	
	// Create the mask for moogaloop
	var v_mask:Sprite = new Sprite();
	with( v_mask.graphics ) {
		beginFill(0x000000, 1);
		drawRect(moogaloop.x, moogaloop.y, player_width, player_height);
		endFill();
	}
	
	addChild(v_mask);
	moogaloop.mask = v_mask;
	
	addChild(moogaloop);
}

function onProgressHandler(e:ProgressEvent):void
{
	var percent:Number = e.bytesLoaded / e.bytesTotal;
	trace(percent);
}

startLoad();
