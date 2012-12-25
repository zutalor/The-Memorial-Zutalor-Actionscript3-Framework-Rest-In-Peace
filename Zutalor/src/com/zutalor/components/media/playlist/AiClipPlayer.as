package com.zutalor.components.media.playlist
{
	import com.gskinner.utils.IDisposable;
	import com.zutalor.components.media.base.MediaPlayer;
	import com.zutalor.components.media.playlist.Playlist;
	import com.zutalor.components.media.playlist.PlaylistItemProperties;
	import com.zutalor.components.media.playlist.PlaylistMediaState;
	import com.zutalor.events.MediaEvent;
	import com.zutalor.events.UIEvent;
	import com.zutalor.properties.NestedPropsManager;
	import com.zutalor.utils.ArrayUtils;
	import com.zutalor.utils.gDictionary;
	import com.zutalor.utils.MasterClock;
	import com.zutalor.utils.MathG;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class AiClipPlayer extends EventDispatcher implements IDisposable 
	{
		public var clipSelector:Function;

		private var _mediaState:PlaylistMediaState;
		private var _sp:MediaStateProperties;
		private var _cueList:Array;
		private var _clipsToPlay:Array;
		private var _clipsAlreadyPlayed:gDictionary;
		private var _stopped:Boolean;
		private var _currentContext:String;
		private var _players:gDictionary;
		private var _playing:int;
		private var _ppm:NestedPropsManager;	
		private var _clipIndex:int;
		private var _framerate:Number;
		private var _volume:Number;
		
		private const TIMER_INTERVAL:int = 1000;
		
		public function initialize(sp:MediaStateProperties, playlist:Playlist):void
		{
			_sp = sp;
			_ppm = playlist.presets;
			_players = new gDictionary();
			_mediaState = new PlaylistMediaState();
			_mediaState.initialize(sp, _players);
			_clipsAlreadyPlayed = new gDictionary();
		}
		
		public function dispose():void
		{
			MasterClock.unRegisterCallback(onTimer);
			_players.dispose();
			_players = null;
			_mediaState.dispose();
			for (var i:int = 0; i < _players.length; i++)
			{
				_players.dispose();
				_players = null;
			}
		}
		
		public function set volume(v:Number):void
		{
			var len:uint;
			var p:MediaPlayer;
						
			len = _players.length;
			for (var i:int = 0; i < len; i++)
			{
				p = _players.getByIndex(i);
				p.volume = v;
			}
			_volume = v;
		}
		
		public function get volume():Number
		{
			return _volume;
		}
		
		public function stop(fade:Number=0):void
		{
			var len:uint;
			var p:MediaPlayer;
			
			MasterClock.stop(onTimer);
			_stopped = true;
			len = _players.length;
			
			for (var i:int = 0; i < len; i++)
			{
				p = _players.getByIndex(i);					
				p.stop(fade);
			}
			if (fade)
				MasterClock.callOnce(onStopComplete, fade * 1000);
			else 
				onStopComplete();
		}
		
		private function onStopComplete(e:Event=null):void
		{
			var p:MediaPlayer;
			
			_playing = 0;
			_cueList = [];
			_clipsToPlay = [];
			_clipsAlreadyPlayed.dispose();
			_clipsAlreadyPlayed = new gDictionary();
		}
		
		public function set framerate(fr:Number):void
		{
			var len:uint;
			var p:MediaPlayer;
			
			_framerate = fr;
			
			len = _players.length;
			for (var i:int = 0; i < len; i++)
			{
				p = _players.getByIndex(i);
				p.framerate = fr;
			}
		}		
		
		public function get framerate():Number
		{
			return _framerate;
		}
		
		public function cued():int
		{
			return _cueList.length;
		}
	
		public function start(volume:Number):void
		{
			_volume = volume;
			_stopped = false;	
			MasterClock.registerCallback(onTimer, true, TIMER_INTERVAL);
			playNext(); // starts the automatic cycle.
		}
		
		public function playNext():void
		{
			var pip:PlaylistItemProperties;
			var p:MediaPlayer;
			var name:String;
			var alreadyReset:Boolean;

			if (!_stopped)
			{
				if (_playing < _sp.minClips || (_playing < _sp.maxClips))
				{
					_playing++;
					if (!_cueList || !_cueList.length)
						cueClipsToPlay("playnext");
						
					if (MathG.rand(1, _sp.oddsOfPlaying) == MathG.rand(1, _sp.oddsOfPlaying))
					{	
						if (!_sp.allowRepeats)
							if (_clipsAlreadyPlayed.count(_currentContext) == _clipsToPlay.length) // we've played each one with no repeats, so reset.
							{
								_clipsAlreadyPlayed.deleteByValue(_currentContext);
								cueClipsToPlay("not allow repeats");		
							}	
						do 
						{
							name = _cueList.shift();		
							if (!_sp.allowRepeats)
								if (!_clipsAlreadyPlayed.getByKey(name))
								{
									_clipsAlreadyPlayed.insert(name, _currentContext);
									break;	
								}	
								
						} while (_cueList.length);						
					}
							
					p = getClipAndPlayIt(name);				
			
					if (!p)
					{
						MasterClock.registerCallback(onTimer, true, 50);
						_playing--;
					}	
					else	
					{
						MasterClock.registerCallback(onTimer, true, TIMER_INTERVAL)
						if (_framerate)
							p.framerate = _framerate;
										
						p.addEventListener(MediaEvent.PLAY, onPlayStarted, false, 0, true);
						p.x = _sp.playlist.x;
						p.y = _sp.playlist.y;
						
						if (_sp.overlap)
							p.addEventListener(MediaEvent.OVERLAP, cueNext, false, 0, true);
						else	
							p.addEventListener(MediaEvent.COMPLETE, cueNext, false, 0, true);
					}
					
				}
			}
		}
		
		private function onPlayStarted(e:MediaEvent):void
					{
						e.target.removeEventListener(MediaEvent.PLAY, onPlayStarted);
						trace("started", e.target.name, e.target);
						dispatchEvent(new MediaEvent(MediaEvent.PLAY));
					}
		
		public function cueNext(me:MediaEvent = null):void
		{
			var pip:PlaylistItemProperties;
			var p:MediaPlayer;
			
			if (me)
			{
				if (me.type == MediaEvent.OVERLAP)
					me.target.removeEventListener(MediaEvent.OVERLAP, cueNext);
				else
					me.target.removeEventListener(MediaEvent.COMPLETE, cueNext);
			}
			if (me)
			{
				if (_playing > 0)
					_playing--;
			}
			
			if (!_stopped) 
				if (_cueList.length < _sp.clipsCacheSize)
				{
					if (_clipIndex == _clipsToPlay.length)
						_clipIndex = 0;
					pip = _ppm.getItemPropsByName(_sp.playlist.playlistName, _clipsToPlay[_clipIndex]);
					if (pip)
					{
						if (!(!_volume && pip.url.indexOf(".mp3") != -1))
							if (!_players.getByKey(pip.name) && _cueList.indexOf(pip.name) == -1)
							{
								p = _mediaState.change(null, UIEvent.CUE_UP, pip)
								if (p)
									_cueList.push(pip.name);
							}
					}
					_clipIndex++;
				}
		}
		
		private function cueClipsToPlay(debug:String= null):void
		{
			var pip:PlaylistItemProperties;
			
			trace(debug);
			_clipsToPlay = [];
			_clipIndex = 0;
							
			for (var i:int = 0; i < _sp.layerClipNames.length; i++)
			{
				pip = _ppm.getItemPropsByName(_sp.playlist.playlistName, _sp.layerClipNames[i]);
				if (!(!_volume && pip.url.indexOf(".mp3") != -1)) // don't play if volume is 0
					if (clipSelector != null)
					{
						if (clipSelector(pip.context))
						{
							_clipsToPlay.push(_sp.layerClipNames[i]);
						}
					}
					else
						_clipsToPlay.push(_sp.layerClipNames[i]);
			}
			fillClipCache();
		}
		
		// PRIVATE METHODS
		
		private function onTimer():void
		{
			cueNext();
			playNext();
		}
				
		private function getClipAndPlayIt(name:String, alreadyReset:Boolean = false):MediaPlayer
		{
			var p:MediaPlayer;
			
			p = _mediaState.change(name, UIEvent.PLAY);

			if (!p)
			{
				if (_cueList.length)
				{
					name = _cueList.shift();
					p = getClipAndPlayIt(name)
				}
				else if (!alreadyReset)
				{
					if (!_sp.allowRepeats)
						_clipsAlreadyPlayed.deleteByValue(_currentContext);
										
					cueClipsToPlay("get clip and play it");
				}
			}		
			return p;
		}		
				
		private function fillClipCache():void
		{
			var pip:PlaylistItemProperties;
			var a:Array;
			var i:int;
			
			_cueList = [];	
			if (_clipsToPlay.length)
			{
				if (_sp.clipsCacheSize)
				{
					a = [];	
					for (i = 0; i < _clipsToPlay.length; i++)
						a[i] = i;
					
					ArrayUtils.shuffle(a);
					
					for (i = 0; i < _clipsToPlay.length; i++)
					{
						pip = _ppm.getItemPropsByName(_sp.playlist.playlistName, _clipsToPlay[a[i]]);
						_cueList.push(pip.name);	
					}
				}
			}
		}
	}
}