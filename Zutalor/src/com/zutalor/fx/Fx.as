package com.zutalor.fx
{
	import com.greensock.*;
	import com.zutalor.containers.*;
	import com.zutalor.utils.*;
	import flash.display.*;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
		 
	public class Fx
	{	
		private var _dc:DisplayObjectContainer;
		private var _name:String;
		private var _fxType:String;
		private var _ease:Function;
		private var _seconds:Number;
		private var _delay:Number;
		private var _value:Number;
		private var _tweenObject:Object;
		
		private var _onComplete:Function;
		private var _onCompleteParams:*;
		
		public function render(dc:DisplayObjectContainer, fxType:String, ease:Function, seconds:Number, delay:Number, value:Number, onComplete:Function=null, onCompleteParams:*=null):void
		{
			_onComplete = onComplete;
			_onCompleteParams = onCompleteParams;
			
			if (fxType == TransitionTypes.NONE)
			{	
				callOnComplete();
			}
			else
			{	
				_dc = dc;
				_fxType = fxType;
				_ease = ease;
				_delay = delay;
				_value = value;
				_seconds = seconds;
				doTransition();
			}	
		}
		
		private function callOnComplete():void
		{
			if (_onComplete != null)
				if (_onCompleteParams)
					_onComplete(_onCompleteParams);
				else
					(_onComplete());
		}
		
		private function doTransition():void
		{			
			_tweenObject = null;
			
			if (_fxType.indexOf(FxTypes.MOVEX) != -1)
				_tweenObject = Move.tweenParams(_dc, _fxType, _value);
			
			if (_fxType.indexOf(FxTypes.MOVEX) != -1)
				_tweenObject = Move.tweenParams(_dc, _fxType, _value);				

			if (_tweenObject)
					TweenMax.to(_dc, _seconds, ObjectUtil.concat(_tweenObject, { delay:_delay, onComplete:fxFinished, ease:_ease } ));
		}
				
		private function fxFinished():void
		{								
			callOnComplete();
		}		
	}
}