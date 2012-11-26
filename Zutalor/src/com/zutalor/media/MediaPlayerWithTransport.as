package com.zutalor.media 
{
	import com.zutalor.containers.ViewObject;
	import com.zutalor.containerUtils.ContainerLoader;
	import com.zutalor.events.MediaEvent;
	import com.zutalor.events.MediaLoadProgressEvent;
	import com.zutalor.events.UIEvent;
	import com.zutalor.propertyManagers.AppContainerPropsManager;
	import com.zutalor.ui.DrawGraphics;
	import com.zutalor.utils.MasterClock;
	import com.zutalor.utils.StageRef;
	import com.soulwire.utils.display.Alignment;
	import com.soulwire.utils.display.DisplayUtils;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class MediaPlayerWithTransport extends MediaPlayer
	{	
		private var _transport:ViewObject;
		
		private var _savedVolume:Number;
		private var _savedWidth:int;
		private var _savedHeight:int;
		private var _savedX:int;
		private var _savedY:int;
		private var _savedScaleX:Number;
		private var _savedScaleY:Number;
		private var _savedParent:DisplayObjectContainer;
		private var _transportLoader:ViewObjectLoader;				
		private var _maximized:Boolean;			

		private const TRANSPORT_PADDING:int = 25;
		
		//PUBLIC METHODS
		
		override public function initTransport(transportViewId:String, transportContainer:String):void
		{
			_transportLoader = new ContainerLoader();
			_transportLoader.load(transportContainer, "", transportViewId);
			_transport = _transportLoader.container;
			_transport.addEventListener(UIEvent.PLAY_TOGGLE, onTransportClick);				
			_transport.addEventListener(UIEvent.STOP, onTransportClick);				
			_transport.addEventListener(UIEvent.SEEK, onTransportClick);				
			_transport.addEventListener(UIEvent.MUTE_TOGGLE, onTransportClick);				
			_transport.addEventListener(UIEvent.VOLUME, onTransportClick);	
			addChild(_transport.viewController.container);
			_transport.y =  height - _transport.height - TRANSPORT_PADDING;
			_transport.x = (width * .5) - (_transport.width * .5);
		}	
		
		
		//PROTECED METHOD OVERRIDES
		
		override protected function onLoadProgress(e:MediaLoadProgressEvent):void
		{
			if (_transport.visible)
				_transport.viewController.setModelValue("percentLoaded", e.percentLoaded);
		}		
					
		override protected function setPlayPauseButton(e:Event=null):void
		{
			_transport.viewController.setModelValue("playing", mediaController.isPlaying);
		}		
				
		override protected function onPlayStarted(me:MediaEvent=null):void
		{
			super.onPlayStarted(me);
			_transport.viewController.setModelValue("volume", volume);
			_transport.viewController.setModelValue("totalTime", mediaController.totalTime);				
		}
		
		//PUBLIC METHOD OVERRIDES
								
		override public function dispose():void
		{
			super.dispose();
			if (_maximized)
				minimize();
			
			StageRef.stage.removeEventListener(Event.RESIZE, minimize);	
				
			_transport.removeEventListener(MouseEvent.CLICK, onTransportClick);	
			_transport.removeEventListener(UIEvent.PLAY_TOGGLE, onTransportClick);				
			_transport.removeEventListener(UIEvent.STOP, onTransportClick);				
			_transport.removeEventListener(UIEvent.SEEK, onTransportClick);				
			_transport.removeEventListener(UIEvent.MUTE_TOGGLE, onTransportClick);				
			_transport.removeEventListener(UIEvent.VOLUME, onTransportClick);
			_transport.dispose();
			_transport = null;				
		}
		
		override public function load(url:String, defaultVolume:Number = 1, playerWidth:int = 0, playerHeight:int = 0, scaleToFit:Boolean = true, bufferTime:Number=0):void
		{		
			super.load(url, defaultVolume, playerWidth, playerHeight, scaleToFit, bufferTime);
			if (_maximized)
				minimize();		
		}
								
		override public function set volume(v:Number):void
		{
			super.volume = v;
			if (_transport)
				_transport.viewController.setModelValue("volume", v);				
		}
		
		override public function onPlayProgress():void
		{
			super.onPlayProgress();
			if (_transport.visible)
			{
				_transport.viewController.setModelValue("percentPlayed", mediaController.percentPlayed);
				_transport.viewController.setModelValue("currentTime", mediaController.currentTime);
			}
		}
		
		// PRIVATE METHODS
		
		private function toggleMaximize():void
		{
			var pt:Point;
			var scale:Number;
			
			if (_maximized) {
				minimize();
			} 
			else
			{	
				_maximized = true;
				_savedWidth = mediaController.view.width;
				_savedHeight = mediaController.view.height;								
				_savedX = this.x;
				_savedY = this.y;
				_savedParent = this.parent;
				StageRef.stage.addChild(this);	
				
				var background:Sprite = new Sprite();
				var area:Rectangle = new Rectangle( 0, 0, StageRef.stage.stageWidth, StageRef.stage.stageHeight);	

				DrawGraphics.box(background, StageRef.stage.stageWidth, StageRef.stage.stageHeight);
				DisplayUtils.fitIntoRect(mediaController.view, area, false, Alignment.MIDDLE );
				
				addChildAt(background, 0);
	
				pt = globalToLocal(new Point(0, 0));
				this.x += pt.x;
				this.y += pt.y;
				StageRef.stage.addEventListener(Event.RESIZE, minimize, false, 0, true);
			}
		}
		
		private function minimize():void
		{	
			if (_maximized)
			{
				var area:Rectangle = new Rectangle( 0, 0, _savedWidth, _savedHeight);

				StageRef.stage.removeEventListener(Event.RESIZE, minimize);
				_maximized = false;
				removeChildAt(0);
				mediaController.view.width = _savedWidth;
				mediaController.view.height = _savedHeight;
				this.x = _savedX;
				this.y = _savedY;
				_savedParent.addChild(this);
				_transport.scaleX = _transport.scaleY = 1;
				_transport.x = (this.width >> 1) - (_transport.width >> 1);
				DisplayUtils.fitIntoRect(mediaController.view, area, false, Alignment.MIDDLE );
			}
		}			
		
		private function onTransportClick(e:UIEvent):void
		{			
			switch (e.type) 
			{
				case UIEvent.PLAY_TOGGLE :
					if (!mediaController.isPlaying)
						play();
					else
						pause();
					break;	
				case UIEvent.STOP :
					stop();
					break;
				case UIEvent.SEEK :
					mediaController.seekToPercent(_transport.viewController.getModelValue("percentPlayed"));
					break;
				case UIEvent.VOLUME :
					mediaController.volume = _volume = _transport.viewController.getModelValue("volume");
					break;
				case UIEvent.MUTE_TOGGLE :
					if (this.volume == 0)
						this.volume = savedVolume;
					else
					{
						savedVolume = this.volume;
						this.volume = 0;
					}
					break;
				case UIEvent.FULLSCREEN :
					toggleMaximize();
					break;
			}
		}		
	}
}