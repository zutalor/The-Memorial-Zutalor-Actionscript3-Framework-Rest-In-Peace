package com.zutalor.ui  
{
	import com.greensock.TweenMax;
	import com.zutalor.properties.ApplicationProperties;
	import com.zutalor.properties.ToolTipProperties;
	import com.zutalor.propertyManagers.Presets;
	import com.zutalor.text.TextUtil;
	import com.zutalor.utils.Scale;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ToolTip
	{					
		private static var _txt:TextField;
		private static var _background:Sprite;
		private static var _textSprite:Sprite;
		private static var _pr:Presets;
		private static var _tp:ToolTipProperties;
		private static var _stageRef:Stage;
		private static var _initialized:Boolean;
		private static var _toolTip:Sprite;
		private static var _ap:ApplicationProperties;
		
		public static function init(stageRef:Stage):void
		{
			_stageRef = stageRef;
			_pr = Presets.gi();
			_ap = ApplicationProperties.gi();
			_background = new Sprite();
			_textSprite = new Sprite();
			_txt = new TextField();	
			_toolTip = new Sprite();			
			_toolTip.addChild(_background);
			_toolTip.addChild(_textSprite);
			_initialized = true;
		}
				
		public static function show(toolTipText:String, toolTipPreset:String, xPos:int=0, yPos:int=0):void
		{
			if (toolTipText)
			{
				if (!_initialized)
					throw new Error("ToolTip must be initialized before use.");
					
				_tp = _pr.toolTipPresets.getPropsByName(toolTipPreset);
				
				if (!xPos)
					_stageRef.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
			
			
				_txt.htmlText = toolTipText;
				
				TextUtil.applyTextAttributes(_txt, _tp.textAttributes, _tp.width, _tp.height);  
			
				_textSprite.addChild(_txt);				
				
				_toolTip.visible = true;
				_toolTip.alpha = 0;	
				TweenMax.to(_toolTip, _tp.fadeTime, { alpha:1, delay:_tp.delay } );
				
				if (!xPos)
				{
					_toolTip.x = _stageRef.mouseX + _tp.hPadBackground;
					_toolTip.y = _stageRef.mouseY - _toolTip.height + _tp.vPadBackground;
				}
				else
				{
					_toolTip.x = xPos + _tp.hPadBackground;
					_toolTip.y = yPos - _toolTip.height + _tp.vPadBackground;					
				}
				
				_toolTip.scaleX = _toolTip.scaleY = Scale.curAppScale;
				
				_stageRef.addChild(_toolTip); // ensure it's always on top.
			}
		}
		
		public static function hide():void
		{
			_stageRef.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);		
			_txt.text = "";				
			_toolTip.visible = false;
		}			
		
		private static function onMouseMove(me:MouseEvent):void
		{
			_toolTip.x = _stageRef.mouseX + _tp.hPadBackground;
			_toolTip.y = _stageRef.mouseY - _toolTip.height + _tp.vPadBackground;
			me.updateAfterEvent();
		}
	}
}