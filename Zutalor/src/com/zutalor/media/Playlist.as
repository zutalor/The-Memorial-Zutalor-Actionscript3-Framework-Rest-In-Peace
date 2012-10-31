package com.zutalor.media
{
	import com.greensock.TweenMax;
	import com.gskinner.utils.IDisposable;
	import com.zutalor.events.HotKeyEvent;
	import com.zutalor.events.MediaEvent;
	import com.zutalor.events.UIEvent;
	import com.zutalor.plugin.constants.PluginMethods;
	import com.zutalor.properties.PlaylistItemProperties;
	import com.zutalor.properties.PlaylistProperties;
	import com.zutalor.propertyManagers.NestedPropsManager;
	import com.zutalor.propertyManagers.Props;
	import com.zutalor.utils.gDictionary;
	import com.zutalor.utils.HotKeyManager;
	import com.zutalor.utils.MasterClock;
	import com.zutalor.utils.Scale;
	import com.zutalor.utils.StageRef;
	import com.zutalor.view.ViewLoader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Playlist extends Sprite implements IDisposable
	{	
		public static const IMAGE:String = "image";
		public static const VIDEO:String = "video";
		public static const MC:String = "mc";
		public static const AUDIO:String = "audio";
		
		public static const GET_FILTER:String = "getFilter";
		
		public static const CONTROL_KEYS:String = UIEvent.PLAY + UIEvent.STOP + UIEvent.PAUSE + UIEvent.FF + UIEvent.REW
													+ UIEvent.SELECT + UIEvent.CANCEL + UIEvent.NEXT + UIEvent.PREVIOUS;
		
		public static const STOP_ALL:String = UIEvent.STOP_ALL
		private static const RECYCLE:String = UIEvent.RECYCLE;
		private static const TIMER_INTERVAL:uint = 1000;
		
		private var _hkm:HotKeyManager;
		private var _pp:PlaylistProperties;
		private var _ppm:NestedPropsManager;
		private var _playlistName:String;
		private var _players:gDictionary;
		private var _selecting:Boolean;
		private var _selectedItem:String;
		private var _curItemName:String;
		private var _isPaused:Boolean;
			
		private var _clipNames:Array;
		private var _aiPlayer:AiClipPlayer;
		private var _autoPlaying:Boolean;
		
		public var loopCount:int;
		
		private var _startTimeMs:Number;
		private var _totalTimeMs:Number;		

		private var _toolsLoader:ViewLoader;
		
		// ai properties
		private var _minClips:int;
		private var _maxClips:int;
		private var _oddsOfPlaying:int;
		private var _clipsCacheSize:int;
		private var _width:int;
		private var _height:int;
		private var _numPlaylistItems:int;
		private var _endIndex:int;
		private var _currentPlaylistIndex:int;	
		
		public var hasStarted:Boolean;
		public var isPlaying:Boolean;
		
		private var _volume:Number;
		
		public var toolsLayer:Sprite;
		
		private var _state:PlaylistMediaState;
		
		private var _onComplete:Function;
				
		public function Playlist()
		{
			
		}
				
		public function create(playlistName:String, viewItemName:String, width:int, height:int):void 
		{
			var pip:PlaylistItemProperties;
			var i:int;
			var sp:MediaStateProperties;
			
			this.name = viewItemName;
			_volume = 1;
			_playlistName = playlistName;
			_width = width;
			_height = height;
			_hkm = new HotKeyManager();
			_players = new gDictionary();
			_ppm = Props.playlists;
			_hkm.addEventListener(HotKeyEvent.HOTKEY_PRESS, onHotKey, false, 0, true);
			_pp = _ppm.getPropsById(_playlistName);
			
			toolsLayer = new Sprite();
			_state = new PlaylistMediaState();
			sp = new MediaStateProperties();
			sp.playlist = this;
			sp.clipFadeOut = _pp.clipFadeOut;
			sp.overlap = _pp.overlap;
			_state.initialize(sp,_players);
			
			MasterClock.registerCallback(onTimer, false, TIMER_INTERVAL);	

			if (_pp.toolsAttached)
				addChild(toolsLayer);
			
			_numPlaylistItems = _ppm.getNumItems(playlistName);	
			
			_endIndex = _numPlaylistItems;	
			_currentPlaylistIndex = _pp.startIndex;
			
			if (!_pp.endIndex)
				_endIndex = _numPlaylistItems;
			else
				_endIndex = _pp.endIndex;
				
			if (_pp.startIndex > _endIndex)
				_endIndex = _pp.startIndex + 1;
				
			if (_endIndex > _numPlaylistItems)
				_endIndex = _numPlaylistItems;	
		
			if (_pp.ai)
			{
				_minClips = _pp.minClips;
				_maxClips = _pp.maxClips;				
				_oddsOfPlaying = _pp.oddsOfPlaying;
				_clipsCacheSize = _maxClips + 1;
				
				_aiPlayer = new AiClipPlayer();
				_clipNames =  [];
			}	
			
			for (i = 0; i < _numPlaylistItems; i++)
			{
				pip = _ppm.getItemPropsByIndex(playlistName, i);
				if (pip.hotkey)
				{
					_hkm.addMapping(StageRef.stage, pip.hotkey, pip.name);
				}					
				_clipNames.push(pip.name);
			}
			
			if (_pp.toolsContainer)
				initTools();

				
			initAi();	
			if (_pp.autoPlay)
			{			
				isPlaying = true;
				if (_pp.ai)
				{
					startAi();
					_autoPlaying = true;
				}
				else
				{
					playNext();	
					_autoPlaying = true;
				}
				_autoPlaying = true;
			}	

		}
		
		public function addMediaPlayer(p:MediaPlayer):void
		{
			addChildAt(p.view, 0);
			p.visible = false;
			if (_pp.toolsAttached)
				addChild(toolsLayer);
		}
		
		override public function set width(w:Number):void
		{
			_width = w;
		}
		
		override public function set height(h:Number):void
		{
			_height = h;
		}
		
		override public function get width():Number
		{
			return _width;
		}
		
		override public function get height():Number
		{
			return _height;
		}
		
		private function initAi():void
		{
			if (_clipNames.length)
			{
				var sp:MediaStateProperties = new MediaStateProperties;
				
				sp.layerClipNames = _clipNames;
				sp.oddsOfPlaying = _oddsOfPlaying;
				sp.clipsCacheSize = _clipsCacheSize;
				sp.minClips = _minClips;
				sp.maxClips = _maxClips;						
				sp.playlist = this;
				sp.clipFadeOut = _pp.clipFadeOut;
				sp.overlap = _pp.overlap;
				sp.allowRepeats = _pp.allowRepeats;
				_aiPlayer.initialize(sp);
			}
		}
		
		public function dispose():void
		{
			// TODO
			MasterClock.unRegisterCallback(onTimer);
		}
		
		public function get numPlaylistItems():int 
		{
			return _numPlaylistItems;
		}
		
		public function get endIndex():int
		{
			return _endIndex;
		}
		
		public function get currentPlaylistIndex():int
		{
			return _currentPlaylistIndex;
		}
		
		public function set currentPlaylistIndex(i:int):void
		{
			_currentPlaylistIndex = i;
		}
		
		public function get playlistName():String
		{
			return _playlistName;
		}
		
		public function set totalTime(seconds:Number):void
		{
			_totalTimeMs = seconds * 1000;
		}
		
		public function play():void
		{
			var numPlayers:int;
			var p:MediaPlayer;
			var i:int;
			
			if (!isPlaying)
			{
				isPlaying = true;
				if (_pp.ai)
					startAi();
				else
					playNext();	
			}
			else if (_isPaused)
			{
				_isPaused = false;
			
				numPlayers = _players.length;	
				for (i = 0; i < numPlayers; i++)
				{
					p = _players.getByIndex(i);
					p.play();			
				}			
			}
			_startTimeMs = getTimer();
			MasterClock.start(onTimer);
			if (_pp.ai)
				_aiPlayer.playNext();
		}
		
		public function pause():void
		{
			var numPlayers:int;
			var p:MediaPlayer;
		
			throw new Error("Playlist pause is buggy.");
			
			_isPaused = true;
			MasterClock.stop(onTimer);
			
			numPlayers = _players.length;	
			for (var i:int = 0; i < numPlayers; i++)
			{
				p = _players.getByIndex(i);
				if (p.name.indexOf(RECYCLE) == -1)
					if (p.isPlaying)
						p.pause();			
			}
		}
		
		public function stop(fadeSecs:Number=-1, onComplete:Function = null):void
		{
			var numPlayers:int;
			var p:MediaPlayer;
			var fadeOut:Number;
			var i:int;
			
			_onComplete = onComplete;
			
			MasterClock.stop(onTimer);
			
			if (fadeSecs == -1)
				fadeOut = 0;
			else if (fadeSecs)
				fadeOut = fadeSecs;
			else
				fadeOut = _pp.endFadeOut;
			
			_autoPlaying = false;
			_isPaused = false;
			isPlaying = false;
			hasStarted = false;
			
			if (_pp.ai)
			{
				if (_aiPlayer) 
					_aiPlayer.stop(fadeOut);
			}				
			else
			{
				numPlayers = _players.length;	
				
				for (i = 0; i < numPlayers; i++)
				{
					p = _players.getByIndex(i);
					if (p.name.indexOf(RECYCLE) == -1)
						p.stop(fadeOut);
				}
			}
			MasterClock.callOnce(onStopComplete, fadeOut * 1000);
		}
		
		public function set framerate(fr:int):void
		{
			_aiPlayer.framerate = fr;
		}
		
		public function set volume(v:Number):void
		{
			_aiPlayer.volume = v;
			_volume = v;
		}
		
		public function get volume():Number
		{
			return _volume;
		}
		
		public function get aiPlayer():AiClipPlayer
		{
			return _aiPlayer;
		}
		
		// PRIVATE METHODS
		
		private function onStopComplete():void
		{			
			if (_onComplete != null)
				_onComplete();
				
			dispatchEvent(new MediaEvent(MediaEvent.COMPLETE));
		}	
		
		private function onTimer():void
		{
			if (_totalTimeMs && getTimer() >= _startTimeMs + _totalTimeMs)
				stop(_pp.endFadeOut);
		}
		
		private function startAi(uie:*=null):void
		{
			if (_autoPlaying)
				return;
			
			_autoPlaying = true;
			
			if (_clipNames.length)
			{
				_aiPlayer.addEventListener(MediaEvent.PLAY, onPlayStarted);
				_aiPlayer.start(_volume);
			}
		}
		
		private function onPlayStarted(me:MediaEvent):void
		{
			me.target.removeEventListener(MediaEvent.PLAY, onPlayStarted);
			dispatchEvent(new MediaEvent(MediaEvent.PLAY));
		}
							
		private function initTools():void
		{			

			_toolsLoader = new ViewLoader();
			_toolsLoader.load(_pp.toolsView);
			_toolsLoader.container.addEventListener(UIEvent.PLAY, play);
			_toolsLoader.container.addEventListener(UIEvent.PLAY_TOGGLE, play);
			_toolsLoader.container.addEventListener(UIEvent.NEXT, next);
			_toolsLoader.container.addEventListener(UIEvent.PREVIOUS, prev);		
				
			if (_pp.toolsAttached)
				toolsLayer.addChild(_toolsLoader.container);
		
		}
		
		private function next(e:Event):void
		{
			playbackControl(UIEvent.NEXT);
		}
		
		private function prev(e:Event):void
		{
			playbackControl(UIEvent.PREVIOUS);
		}
				
		private function playNext(me:MediaEvent = null):void
		{
			var pip:PlaylistItemProperties;
			var p:MediaPlayer;
			
			if (me)
				me.target.removeEventListener(MediaEvent.OVERLAP, playNext);
				
			if (_currentPlaylistIndex < _endIndex)
			{		
				pip = _ppm.getItemPropsByIndex(_playlistName, _currentPlaylistIndex);
				
				if (!_players.getByKey(pip.name))
				{
					p = _state.change(null, UIEvent.PLAY, pip);
					if (p)
					{
						p.addEventListener(MediaEvent.OVERLAP, playNext, false, 0, true);
						_currentPlaylistIndex++;
					}
				}			
			}
			
			if (_currentPlaylistIndex == _endIndex)
			{
				if (_pp.loop)
				{
					if (_pp.loop == -1)
						_currentPlaylistIndex = _pp.startIndex;
					else if (loopCount)
					{
						loopCount--
						_currentPlaylistIndex = _pp.startIndex;
					}
					playNext();
				}
			}
			if (_currentPlaylistIndex > 1)
				_toolsLoader.container.viewController.callUXControllerMethod(PluginMethods.SET_PREV_BUTTON_VISIBILITY, true);
			else	
				_toolsLoader.container.viewController.callUXControllerMethod(PluginMethods.SET_PREV_BUTTON_VISIBILITY, false);
				
			if (_currentPlaylistIndex < _endIndex)	
				_toolsLoader.container.viewController.callUXControllerMethod(PluginMethods.SET_NEXT_BUTTON_VISIBILITY, true);
			else	
				_toolsLoader.container.viewController.callUXControllerMethod(PluginMethods.SET_NEXT_BUTTON_VISIBILITY, false);
		}
		
		public function onHotKey(hke:HotKeyEvent):void
		{
			if (_pp.respondToControlKeys)
				playbackControl(hke.message);
			else if (CONTROL_KEYS.indexOf(hke.message) == -1)
				playbackControl(hke.message);
		}
				
		public function playbackControl(stateOrItemName:String):void
		{	
			var p:MediaPlayer;
			
			switch (stateOrItemName)
			{
				case UIEvent.SELECT :
					_selecting = true;
					//trace("selecting");
					break;
				case UIEvent.CANCEL :
					_selecting = false;
					_selectedItem = null;
					//trace(CANCEL);
					break;
				case UIEvent.STOP_ALL :
					stop();
					break;					
				case UIEvent.NEXT :
					if (_currentPlaylistIndex < _endIndex)
					{
						if (_state.curItemName)
						{	
							p = _players.getByKey(_state.curItemName);
							if (p)
								p.stop(_pp.clipFadeOut);
						}
						playNext();
					}
					break;
				case UIEvent.PREVIOUS :
					if (_currentPlaylistIndex)
					{
						if (_currentPlaylistIndex == 1)
							_currentPlaylistIndex = 0;
						else if (_currentPlaylistIndex > 1)
							_currentPlaylistIndex -= 2;						
						else if (_pp.loop)
							_currentPlaylistIndex = _endIndex - 1;
						
						if (_state.curItemName)
						{	
							p = _players.getByKey(_state.curItemName);
							if (p)
								p.stop(_pp.clipFadeOut);
						}
						playNext();
					}
					break;
				case UIEvent.PLAY :
				case UIEvent.STOP :
				case UIEvent.PAUSE :
				case UIEvent.FF :
				case UIEvent.REW :
					if (_selectedItem)
					{
						_state.change(_selectedItem, stateOrItemName);
						_selectedItem = null;
						//trace(stateOrItemName + ": ", _selectedItem);
					}
					else
					{
						_state.change(_state.curItemName, stateOrItemName);
						//trace(stateOrItemName + ": ", _state.curItemName);
					}
					break;
					
				default :
					if (_selecting)
					{
						_selectedItem = stateOrItemName;
						_selecting = false;
						//trace("Selected:", _selectedItem);
					}
					else
						_state.change(stateOrItemName);
					break;
			}
		}
	}
}