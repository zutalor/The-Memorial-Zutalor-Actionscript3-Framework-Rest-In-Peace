package com.zutalor.components.media.playlist
{	
	import com.gskinner.utils.IDisposable;
	import com.zutalor.components.media.base.MediaPlayer;
	import com.zutalor.components.media.video.VideoPlayer;
	import com.zutalor.events.MediaEvent;
	import com.zutalor.events.UIEvent;
	import com.zutalor.plugin.Plugins;
	import com.zutalor.properties.NestedPropsManager;
	import com.zutalor.utils.gDictionary;
	import com.zutalor.utils.MathG;
	import com.zutalor.utils.ShowError;
	import flash.events.EventDispatcher;
	
	public class PlaylistMediaState extends EventDispatcher implements IDisposable
	{
		private static const RECYCLE:String = "__R";	
		public static const VIDEO:String = "video";	
		public static const AUDIO:String = "audio";	
		public static const IMAGE:String = "image";
		
		private var _ppm:NestedPropsManager;
		private var _pp:PlaylistProperties;		
		private var _curItemName:String;
		private var _sp:MediaStateProperties;
		private var _players:gDictionary;
		
		public var PlayerClass:Class;

		
		public function PlaylistMediaState()
		{
		}
		
		public function initialize(sp:MediaStateProperties, players:gDictionary):void
		{
			_sp = sp;
			if (_sp.clipsCacheSize < _sp.maxClips + 2)
				_sp.clipsCacheSize = _sp.maxClips + 2;
				
			_ppm = sp.playlist.presets;
			_pp = sp.playlist.presets.getPropsById(sp.playlist.playlistName);
			
			if (_pp.playerClassName)
				PlayerClass = Plugins.getClass(_pp.playerClassName);
			else
				ShowError.fail(PlaylistMediaState,"PlaylistMediaState: no playerClassName defined");
			
			_players = players;
		}
				
		public function get curItemName():String
		{
			return _curItemName;
		}
		
		public function dispose():void
		{
			//TODO
		}
		
		public function set players(players:gDictionary):void
		{
			_players = players;
		}
		
		public function change(itemName:String=null, state:String=null, pip:PlaylistItemProperties = null):*	
		{
			var p:*;
			var playListIndex:int;
			var extension:String;							

			if (!pip)
				pip = _ppm.getItemPropsByName(_sp.playlist.playlistName, itemName);
			
			if (pip) // otherwise itemName is for a different playlist
			{
				if (itemName)
				{
					playListIndex = _ppm.getItemIndexByName(_sp.playlist.playlistName, itemName);				
					if (playListIndex >= _pp.startIndex	&& playListIndex < _sp.playlist.endIndex)
						_sp.playlist.currentPlaylistIndex = playListIndex;
				}
				
				if (!state)
				{
					if (_players.getByKey(pip.name))
						state = pip.hotkeyTriggerMode;
					else
						state = UIEvent.PLAY;
				}
				
				if (pip.url)
					_curItemName = pip.name;
						
				switch (state)
				{
					case UIEvent.CUE_UP :
						if (!_players.getByKey(pip.name))
						{
							p = getPlayer(pip, true);
						}
						break;
					case UIEvent.PLAY :
						p = getPlayer(pip, false);
						if (p)
							startPlayback(pip, p);
						break;
					case UIEvent.STOP :
						if (p)
						{
							p.stop(pip.fadeOut);
							//traceAction("Stopping", p);
						}
						break;
					case UIEvent.PAUSE :
						if (p)
						{
							//traceAction("Pausing",p);
							if (p.isPlaying)
								p.pause();
							else
								p.play();
						}
						else
						{								
							p = getPlayer(pip, false);
							startPlayback(pip, p);
						}	
						break;
					case UIEvent.REW : //TODO
						break;
					case UIEvent.FF :
						break;
				}
			}
			return p;
		}
		
		private function getPlayer(pip:PlaylistItemProperties, cueing:Boolean):*
		{
			var p:MediaPlayer;
			var fullUrl:String;
			var i:int;
			
			fullUrl = _pp.path + pip.url;
			p = _players.getByKey(pip.name); // first see if it's already cued up.

			if (p && cueing)
			{
				//traceAction("Already cued, ignoring", p);
				return null;
			}
			else if (p)
			{
				if (p.isPlaying)
				{
					//trace("already playing")
					//traceAction("Already playing", p);
					return null;
				}
				//else
					//traceAction("Playing, using a cued up player", p);
			}
			else if (!p)
			{	
				if (PlayerClass != VideoPlayer)
				{
					for (i = 0; i < _players.length; i++)
					{
						p = _players.getByIndex(i);
						if (p.url == fullUrl)
						{
							//traceAction("Reusing its own player", p);
							break;
						}
						else
							p = null;
					}
				}
				
				if (!p)
					p = _players.getByKey(RECYCLE); // otherwise see if there is a "used" one available.
				
				if (p) 
				{
					
					//if (cueing)
						//traceAction("Cueing using a recycled player", p)
					//else
						//traceAction("Playing using a recycled player", p)
					
					_players.insert(RECYCLE, p, pip.name);
					p.name = pip.name;
				}
				else // otherwise make a new one...
				{
					if (_players.length < _sp.clipsCacheSize)
					{
						p = new PlayerClass("");
						p.name = pip.name;
						//traceAction("Making a new player", p);
						p.returnToZero = false;
						_players.insert(pip.name, p);
					}
					else // or replace an already cued up one
					{
						var cued:MediaPlayer;
						for (i = 0; i < _players.length; i++)
						{
							cued = _players.getByIndex(i);
							{
								if (!cued.isPlaying)
								{
									p = cued;
									_players.insert(cued.name, p, pip.name);
									p.name = pip.name;
									//traceAction("re-place an already cued up player", p);
									break;
								}
							}
						}
					}
				}
			}
			if (p)
			{
				if (!pip.width)
					p.load(fullUrl, _pp.width, _pp.height, _pp.x, _pp.y);
				else	
					p.load(fullUrl, pip.width, pip.height, pip.x, pip.y);
			}	
			return p;
		}
	
		private function startPlayback(pip:PlaylistItemProperties, p:MediaPlayer):void
		{	
			var start:Number;
			var end:Number;
			var vFadeIn:Number;
			var aFadeIn:Number;
			var fadeOut:Number;
			var delay:Number;
			
			p.volume = pip.volume;
			
			if (p.playerType == IMAGE)
			{
				if (!pip.end)
					end = _pp.defaultImageLength;
				
				if (end)	
					p.totalTime = end;
			}
			else
				end = pip.end;
			
			if (!pip.videoFadeIn)
				vFadeIn = _pp.videoFadeIn;
			else
				vFadeIn = pip.videoFadeIn;
					
			if (!pip.audioFadeIn)
				aFadeIn = _pp.audioFadeIn;
			else
				aFadeIn = pip.audioFadeIn;
				
			if (!pip.fadeOut)
				fadeOut = _pp.clipFadeOut;
			else
				fadeOut = pip.fadeOut;
			
			if (!_sp.playlist.hasStarted)
			{
				_sp.playlist.isPlaying = true;
				if (_pp.startDelay)
					delay = _pp.startDelay;
				else
					delay = pip.startDelay;
			}
			else
				delay = pip.startDelay;
				
			_sp.playlist.hasStarted = true;	
			
			if (pip.start)
				start = pip.start;
			else if (_pp.startVariance)
				start = MathG.randFloat(0, _pp.startVariance);
			else
				start = 0;
		
			if (_pp.endVariance)
				p.endVariance = MathG.randFloat(0, _pp.endVariance);	
			
			p.addEventListener(MediaEvent.COMPLETE, recyclePlayer);
			p.audioFadeIn = aFadeIn;
			p.fadeOut = fadeOut;
			p.overlap = _pp.overlap;
			p.start = start;
			p.startDelay = delay;
			p.loop = pip.loop;
			p.loopDelay = pip.loopDelay;
			p.play();
			_sp.playlist.addMediaPlayer(p);
			p.visible = true;
			dispatchEvent(new MediaEvent(MediaEvent.PLAY));
		}
		
		public function recyclePlayer(me:MediaEvent):void
		{
			if (_players.getByKey(me.target.name))
			{
				me.target.visible = false;
				//traceAction("Recycled", p);
				//trace("Recycled", me.target.name, "isPlaying", me.target.isPlaying);
				_players.insert(me.target.name, me.target, RECYCLE);
			}			
		}
		
		private function playNext(p:*):void
		{
			var pip:PlaylistItemProperties;
			
			if (_players.getByKey(p.name))
			{
				pip = _ppm.getItemPropsByName(_sp.playlist.playlistName, p.name);
				if (pip.playNext)
					change(pip.playNext, UIEvent.PLAY);
			}			
		}
		
		/*
		private function //traceAction(message:String, p:*, name:String=null, PlayerClass:Class= null):void
		{
			var limitType:String; // = MediaPlayerTypes.audio;
			var LimitPlayerClass:Class; // = AudioPlayer;
			var numAudioPlayers:int;
			var numVidPlayers:int;
			var i:int;
			var pp:*;
			
			numAudioPlayers = 0;
			numVidPlayers = 0;
			for (i = 0; i < _players.length; i++)
			{
				pp = _players.getByIndex(i);
				if (pp.playerType == MediaPlayerTypes.video)
					numVidPlayers++;
				else if (pp.playerType == MediaPlayerTypes.audio)
					numAudioPlayers++;
			}
			
			if (p)			
			{
				if (p.playerType == limitType || !limitType) 
					trace("PlaylistMediaState: " + p.playerType + " " + message + " : " + p.name);
			}
			else if (PlayerClass == LimitPlayerClass || !LimitPlayerClass)
				{
					trace("PlaylistMediaState: " + String(PlayerClass) + " " + message + " : " + name);
				}
		}
		
		*/
	}
}