package com.zutalor.components.media.playlist
{
	import com.zutalor.components.base.Component;
	import com.zutalor.components.media.base.MediaPlayer;
	import com.zutalor.components.media.base.MediaProperties;
	import com.zutalor.events.HotKeyEvent;
	import com.zutalor.events.MediaEvent;
	import com.zutalor.events.UIEvent;
	import com.zutalor.interfaces.IComponent;
	import com.zutalor.properties.NestedPropsManager;
	import com.zutalor.utils.gDictionary;
	import com.zutalor.utils.HotKeyManager;
	import com.zutalor.utils.MasterClock;
	import com.zutalor.utils.ShowError;
	import com.zutalor.utils.StageRef;
	import com.zutalor.view.properties.ViewItemProperties;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Playlist extends Component implements IComponent
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
		// ai properties
		private var _minClips:int;
		private var _maxClips:int;
		private var _oddsOfPlaying:int;
		private var _clipsCacheSize:int;
		private var _numPlaylistItems:int;
		private var _endIndex:int;
		private var _currentPlaylistIndex:int;	
		
		public var hasStarted:Boolean;
		public var _isPlaying:Boolean;
		
		private var _volume:Number;
		
		private var _state:PlaylistMediaState;
		
		private static var _presets:NestedPropsManager;
				
		public function Playlist(name:String)
		{
			super(name);
		}
		
		public static function registerPresets(options:Object):void
		{
			if (!_presets)
				_presets = new NestedPropsManager();
			
			_presets.parseXML(PlaylistProperties, PlaylistItemProperties, options.xml[options.nodeId], options.childNodeId, 
																							options.xml[options.childNodeId]);
		}
		
		public function get presets():NestedPropsManager
		{
			return _presets;
		}
				
		override public function render(viewItemProperties:ViewItemProperties = null):void 
		{
			super.render(viewItemProperties);
			
			var pip:PlaylistItemProperties;
			var i:int;
			var sp:MediaStateProperties;
			
			_volume = 1;
			vip.playlistName = vip.playlistName;
			_hkm = HotKeyManager.gi();
			_players = new gDictionary();
			_hkm.addEventListener(HotKeyEvent.HOTKEY_PRESS, onHotKey, false, 0, true);
			_pp = _presets.getPropsById(vip.playlistName);
			_state = new PlaylistMediaState();
			sp = new MediaStateProperties();
			sp.playlist = this;
			sp.clipFadeOut = _pp.clipFadeOut;
			sp.overlap = _pp.overlap;
			_state.initialize(sp,_players);
			
			MasterClock.registerCallback(onTimer, false, TIMER_INTERVAL);	
			_numPlaylistItems = _presets.getNumItems(playlistName);	
			
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
				pip = _presets.getItemPropsByIndex(playlistName, i);
				if (pip.hotkey)
				{
					_hkm.addMapping(StageRef.stage, pip.hotkey, pip.name);
				}					
				_clipNames.push(pip.name);
			}
				
			initAi();	
			if (_pp.autoPlay)
			{			
				_isPlaying = true;
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
			addChildAt(p, 0);
			p.visible = false;
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
				_aiPlayer.initialize(sp, this);
			}
		}
		
		override public function dispose():void
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
			return vip.playlistName;
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
			
			if (!_isPlaying)
			{
				_isPlaying = true;
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
		
			ShowError.fail(Playlist,"Playlist pause is buggy.");
			
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
		
		override public function stop(fadeSecs:Number=-1):void
		{
			var numPlayers:int;
			var p:MediaPlayer;
			var fadeOut:Number;
			var i:int;
			
			MasterClock.stop(onTimer);
			
			if (fadeSecs == -1)
				fadeOut = 0;
			else if (fadeSecs)
				fadeOut = fadeSecs;
			else
				fadeOut = _pp.endFadeOut;
			
			_autoPlaying = false;
			_isPaused = false;
			_isPlaying = false;
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
				pip = _presets.getItemPropsByIndex(vip.playlistName, _currentPlaylistIndex);
				
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
		}
		
		public function onHotKey(hke:HotKeyEvent):void
		{
			if (CONTROL_KEYS.indexOf(hke.message) == -1)
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
		
		public function get playerType():String 
		{
			return MediaProperties.PLAYER_PLAYLIST;
		}
		
		public function get view():DisplayObject 
		{
			return this;
		}
		
		public function get isPlaying():Boolean 
		{
			return _isPlaying;
		}
		
		public function set isPlaying(v:Boolean):void
		{
			_isPlaying = v;
		}
	}
}