package com.zutalor.utils
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class TimerRegistery extends Sprite
	{
		private const SIZE:uint = 50;
		private var _callbacks:Array;
		private var _running:Array;
		private var _intervals:Array;
		private var _fireOnce:Array;
		private var _lastTime:Array;
		private var _args:Array;
		private var _defaultInterval:uint;
		
		private var _lastTimeChecked:uint;
		
		private var _isRunning:Boolean;

		public function TimerRegistery()
		{
			_initialize();
		}
		
		private function _initialize():void
		{
			_callbacks = [];
			_running = [];
			_intervals = [];
			_fireOnce = [];
			_lastTime = [];
			_args = [];
			_defaultInterval = 2500;
		}
		
		public function set defaultInterval(interval:uint):void
		{
			if (interval > 0)
				_defaultInterval = interval;
		}
		
		public function get defaultInterval():uint
		{
			return _defaultInterval;
		}
				
		public function registerCallback(callback:Function, autostart:Boolean, interval:uint,
													fireOnce:Boolean = false, args:String = null):void
		{
			var i:int;
			
			if (!interval)
				interval = _defaultInterval;
			
			i = _callbacks.indexOf(callback);

			if (i == -1)
			{
				i = _callbacks.indexOf(null);
				if (i == -1)
					i = _callbacks.length;
					
				_callbacks[i] = callback;
			}

			_intervals[i] = interval;
			_fireOnce[i] = fireOnce;
			_args[i] = args;
			
			
			if (autostart)
			{
				_running[i] = true;
				_lastTime[i] = getTimer();
				startTimer();
			}
			else
			{
				_running[i] = false;
				_lastTime[i] = 0;
			}
		}
		
		public function stop(callback:Function):void
		{
			var i:int;
			
			i = _callbacks.indexOf(callback);

			if (i != -1)
				_running[i] = false;
		}
		
		public function start(callback:Function):void
		{
			var i:int;
			
			i = _callbacks.indexOf(callback);

			if (i != -1)
			{
				_running[i] = true;
				_lastTime[i] = getTimer();
				startTimer();
			}
			else
				trace("TimerRegistery: starting function not found");
		}
		
		public function resetAndStart(callback:Function):void
		{
			var i:int;
			
			i = _callbacks.indexOf(callback);

			if (i != -1)
			{
				_running[i] = true;
				_lastTime[i] = getTimer();
				startTimer();
			}
		}
		
		public function isRegistered(callback:Function):Boolean
		{
			var i:int;
			
			i = _callbacks.indexOf(callback);
			if (i != -1)
				return true;
			else
				return false;
		}
		
		public function modifyInterval(callback:Function, interval:int):void
		{
			var i:int;
			
			i = _callbacks.indexOf(callback);
			if (i != -1)
				_intervals[i] += interval;
		}
		
		public function unRegisterCallback(callback:Function):void
		{
			var i:int;
			i = _callbacks.indexOf(callback);
			if (i != -1)
				_callbacks[i] = null;
		}
		
		// PRIVATE METHODS
		
		private function startTimer():void
		{
			if (!_isRunning)
			{
				this.addEventListener(Event.ENTER_FRAME, checkTimers, false, 0, true);
				_isRunning = true;
			}
		}
		
		private  function checkTimers(e:Event):void
		{
			var t:uint;
			var methodToCall:Function;
			var args:*;
			
			e.stopImmediatePropagation();

			if (!_callbacks.length)
			{
				this.removeEventListener(Event.ENTER_FRAME, checkTimers);
				_isRunning = false;
			}
			else
			{
				t = getTimer();
				for (var i:int = 0; i < _callbacks.length; i++)
				{
					if (_callbacks[i] != null && _running[i] && (t > _lastTime[i] + _intervals[i]))
					{
						methodToCall = _callbacks[i];
						args = _args[i];
						
						if (_fireOnce[i])
							_callbacks[i] = null;
						else
							_lastTime[i] = t;
							
						if (!args)	
							methodToCall();
						else
							methodToCall(args);
					}
				}
			}
		}
	}
}