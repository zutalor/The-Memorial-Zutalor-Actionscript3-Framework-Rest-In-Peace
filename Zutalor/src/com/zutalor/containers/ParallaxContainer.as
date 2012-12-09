package com.zutalor.containers 
{
	import com.zutalor.containers.ScrollingContainer;
	import com.zutalor.events.UIEvent;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.events.Event;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ParallaxContainer extends ScrollingContainer
	{	
		private var _layers:Array;		
		private var _virtualWidth:Array;
		private var _virtualHeight:Array;
		private var _blankShapes:Array;
		private var _trackColor:uint;
		private var _thumbColor:uint;
		private var _closeButtonColor:uint;
		
		private const NUM_LAYERS:int = 5;
		
		private const DFLT_HEIGHT_MULTIPLIER:Number = 1; 
		private const DFLT_HEIGHT_INCREMENT:Number = 1.25;
	
		private const DFLT_WIDTH_MULTIPLIER:Number = 1.5; 
		private const DFLT_WIDTH_INCREMENT:Number = 2;
		
		public function ParallaxContainer(containerName:String) 
		
		// TODO options: numLayers & reverseThumbs
		{
			super(containerName);
			addEventListener(Event.ADDED_TO_STAGE, addedToStage, false, 0, true);
		}	
		
		override public function push(child:DisplayObject, options:Object = null):void  //example options { layerLayer:1, destPercentX:0.5, destPercentY:0.5 }
		{	
			
			var c:ScrollingContainer;
				
			if (options) 
			{
				child.x = _virtualWidth[options.layerNum] * options.destPercentX;
				child.y = _virtualHeight[options.layerNum] * options.destPercentY;
				
				if (options.layerNum == 0)
					super.push(child);
				else
					_layers[options.layerNum].push(child);
			}
			else
				super.push(child);
		}
		
		override public function set height(n:Number):void
		{		
			for (var i:int = 1; i < NUM_LAYERS; i++)
				_layers[i].height = n;			
		}
		
		override public function set width(n:Number):void
		{
			for (var i:int = 1; i < NUM_LAYERS; i++)
				_layers[i].width = n;			
		}	

		override public function tweenScrollPercentY(percent:Number, tweenTime:Number=0.5, ease:Function=null):void
		{
			super.tweenScrollPercentY(percent, tweenTime, ease);
			for (var i:int = 1; i < NUM_LAYERS; i++)
				_layers[i].setScrollPositionY(percent, tweenTime, ease);
		}
		
		override public function tweenScrollPercentX(percent:Number, tweenTime:Number=0.5, ease:Function=null):void
		{
			super.tweenScrollPercentX(percent, tweenTime, ease);
			for (var i:int = 1; i < NUM_LAYERS; i++) {
				_layers[i].setScrollPercentX(percent, tweenTime, ease);
			}
		}
				
		private function addedToStage(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			_layers = [];
			_virtualHeight = [];
			_virtualWidth = [];
			_blankShapes = [];	
			initLayers();
		}
		
		private function reinitializeLayers():void
		{
			for (var i:int = NUM_LAYERS - 1; i > -1; i--)
			{
				if (i) // because '0' is "this"
				{
					_layers[i].push(_blankShapes[i]);
				}
				else
				{
					push(_blankShapes[i]);
				}
			}
		}
		
		private function initLayers():void
		{
			var heightMultiplier:Number;
			var widthMultiplier:Number;
			var heightIncrement:Number;
			var widthIncrement:Number;
	
			widthMultiplier = DFLT_WIDTH_MULTIPLIER; 
			widthIncrement = DFLT_WIDTH_INCREMENT;

			heightMultiplier = DFLT_HEIGHT_MULTIPLIER;
			heightIncrement = DFLT_HEIGHT_INCREMENT;
			
			for (var i:int = NUM_LAYERS - 1; i > -1; i--)
			{
				_virtualWidth[i] = Math.floor(width * widthMultiplier);
				_virtualHeight[i] = Math.floor(height * heightMultiplier);
				
				trace("vH", _virtualHeight[i], "vW",_virtualWidth[i])
				
				_blankShapes[i] = new Shape();
				_blankShapes[i].graphics.beginFill(0, 0);
				_blankShapes[i].graphics.drawRect(_virtualWidth[i]-1, 0, 1, 1);
				_blankShapes[i].graphics.drawRect(0, _virtualHeight[i] - 1, 1, 1);
				_blankShapes[i].graphics.endFill();
			
				if (i) // because '0' is "this"
				{
					_layers[i] = new ScrollingContainer(name + String(i));
					_layers[i].push(_blankShapes[i]);
					addChild(_layers[i]);
					_layers[i].scrollBarsVisible = false;
				}
				else
				{
					push(_blankShapes[i]);
				}
				widthMultiplier *= widthIncrement;
				heightMultiplier *= heightIncrement;
			}
		}
	}
}