﻿package com.zutalor.fx
{
	import com.greensock.*;
	import com.zutalor.containers.*;
	import com.zutalor.propertyManagers.Presets
	import com.zutalor.properties.TransitionProperties;
	import com.zutalor.utils.*;
	import flash.display.*;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
		 
	public class Transition
	{	
		private var _dc:DisplayObject;
		private var _name:String;
		private var _transType:String;
		private var _xValue:Number;
		private var _yValue:Number;
		private var _ease:Function;
		private var _seconds:Number;
		private var _delay:Number;
		private var _inOut:String;
		private var _tweenObject:Object;
		private var _tweenObjectForWipe:Object;
		private var _savedX:int;
		private var _savedY:int;
		private var _savedAlpha:Number;
		private var _mask:Sprite;
		
		private var _onComplete:Function;
		private var _onCompleteParams:*;
		
		public function Transition()
		{
			_mask = new Sprite();
		}
		
		public function simpleRender(dc:DisplayObject, transitionPreset:String, inOut:String, onComplete:Function=null, seconds:Number=-1, delay:Number=-1):void
		{
			var tpp:TransitionProperties;
			_onComplete = onComplete;
			tpp = Presets.gi().transitionPresets.getPropsByName(transitionPreset);
			
			if (tpp)
			{
				_dc = dc;
				
				if (inOut == "in")
				{
					_transType = tpp.inType;
					_xValue = tpp.xValue;
					_yValue = tpp.yValue;
					_ease = tpp.inEase;
					_delay = tpp.inDelay;
					_seconds = tpp.inTime;
				}
				else
				{
					_transType = tpp.outType;
					_xValue = tpp.xValue;
					_yValue = tpp.yValue;
					_ease = tpp.outEase;
					_delay = tpp.outDelay;
					_seconds = tpp.outTime;
				
				}
				
				if (seconds != -1)
					_seconds = seconds;
					
				if (delay != -1)
					_delay = delay;
				
				_inOut = inOut;
				_savedX = dc.x;
				_savedY = dc.y;
				_savedAlpha = dc.alpha;
				doTransition();
			}
		}
		
		public function set seconds(s:Number):void
		{
			_seconds = s;
		}
		
		public function set delay(s:Number):void
		{
			_delay = s;
		}
		
		public function render(dc:DisplayObject, transType:String, ease:Function, seconds:Number, delay:Number,
								inOut:String, xValue:Number, yValue:Number, onComplete:Function = null, onCompleteParams:*= null):void
		{
			_onComplete = onComplete;
			_onCompleteParams = onCompleteParams;
			
			if (transType == TransitionTypes.NONE)
			{		
				callOnComplete();
			}
			else
			{	
				_dc = dc;
				_transType = transType;
				_xValue = xValue;
				_yValue = yValue;
				_ease = ease;
				_inOut = inOut;
				_delay = delay;
				_seconds = seconds;
				_savedX = dc.x;
				_savedY = dc.y;			
				_savedAlpha = dc.alpha;
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
			_tweenObjectForWipe = null;		
						
			if (_transType.indexOf(TransitionTypes.SCALE) != -1)
				_tweenObject = ScaleIt.tweenParams(StandardContainer(_dc), _inOut, _xValue, _yValue);

			if (_transType.indexOf(TransitionTypes.WIPE) != -1)
				_tweenObjectForWipe = Wipe.tweenParams(_dc, _mask, _transType, _inOut);
				
			if (_transType.indexOf(TransitionTypes.FADE) != -1) 
				_tweenObject = FadeObject.tweenParams(_dc, _inOut);
	
			if (_transType.indexOf(TransitionTypes.BLUR) != -1)
				_tweenObject = ObjectUtil.concat(_tweenObject, Blur.tweenParams(_dc, _inOut));
				
			if (_transType.indexOf(TransitionTypes.SLIDE) != -1)
				_tweenObject = ObjectUtil.concat(_tweenObject, Slide.tweenParams(_dc, _transType, _inOut));
			
			if (_transType.indexOf(TransitionTypes.MOVE) != -1)
			{
				_tweenObject = ObjectUtil.concat(_tweenObject, Move.tweenParams(_dc, _transType, _inOut, _xValue, _yValue));
				_savedX = _tweenObject["x"];
				_savedY = _tweenObject["y"];
			}
			
			if (_tweenObject && _tweenObjectForWipe)
			{
				TweenMax.to(_dc, _seconds, _tweenObject);
				_mask = new Sprite();
				_dc.mask = _mask;
				_dc.parent.addChild(_mask);
				TweenMax.to(_mask, _seconds, ObjectUtil.concat(_tweenObjectForWipe, 
											{ delay:_delay, onComplete:fxFinished, ease:_ease } ));	
			}
			else
				if (_tweenObject)
					TweenMax.to(_dc, _seconds, ObjectUtil.concat(_tweenObject, 
											{ delay:_delay, onComplete:fxFinished, ease:_ease } ));
				else
					if (_tweenObjectForWipe) {
						_mask = new Sprite();
						_dc.mask = _mask;
						_dc.parent.addChild(_mask);
						TweenMax.to(_mask, _seconds, ObjectUtil.concat(_tweenObjectForWipe, 
									{ delay:_delay, onComplete:fxFinished, ease:_ease } ));
					} else
						fxFinished();
		}
				
		private function fxFinished():void
		{
			_dc.filters = null;
			_dc.alpha = _savedAlpha;
			_dc.x = _savedX;
			_dc.y = _savedY;
			removeMask();
		
			if (_inOut == TransitionTypes.IN)
				_dc.visible = true;
			else
				_dc.visible = false;
								
			callOnComplete();
		}
		
		private function removeMask():void
		{
			if (_dc.mask) {
				if (_dc.parent) // TODO CHECK THIS
				{
					_dc.parent.removeChildAt(_dc.parent.numChildren - 1);
					_dc.mask = null;
					_mask = null;
				}
			}	
		}
	}
}