package com.zutalor.components
{
	import com.zutalor.containers.AbstractContainer;
	import com.zutalor.interfaces.IViewItem;
	import com.zutalor.properties.ButtonProperties;
	import com.zutalor.propertyManagers.Props;
	import com.zutalor.text.TextUtil;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Button extends AbstractContainer implements IViewItem
	{
		private var _sb:SimpleButton;
		private var _up:Graphic;
		private var _over:Graphic;
		private var _down:Graphic;
		private var _disabled:Graphic;
		private var _name:String;
		private var _enabled:Boolean = true;
		
		public function Button(buttonId:String, text:String = null)
		{
			init(buttonId, text);	
		}

		private function init(buttonId:String, text:String):void
		{
			var bp:ButtonProperties;
			var width:int;
			var height:int;
			var align:String;
			var hPad:int;
			var vPad:int;
			var text:String;
			
			bp = Props.pr.buttonPresets.getPropsByName(buttonId);

			// ToDO throw errors
			
			_up = new Graphic();
			_up.render(bp.upGid);
	
			_over = new Graphic();
			_over.render(bp.overGid);

			_down = new Graphic();
			_down.render(bp.downGid);

			_disabled = new Graphic();
			_disabled.render(bp.disabledGid);
			
			_sb = new SimpleButton(_up, _over, _down, _up);
			this.addChild(_sb);
							
			if (text)
			{
				if (!bp.width) 
				{
					width = _up.width;
					height = _up.height;
				}
				
				align = bp.align;
				hPad = bp.hPad;
				vPad = bp.vPad;

				if (!bp.textAttributesDown)
				{
					bp.textAttributesDown = bp.textAttributesDisabled = bp.textAttributes;
				}
				TextUtil.add(_up, text, bp.textAttributes, width, height, align, hPad, vPad); 
				TextUtil.add(_over, text, bp.textAttributes, width, height, align, hPad, vPad);
				TextUtil.add(_down, text, bp.textAttributesDown, width, height, align, hPad, vPad);
				TextUtil.add(_disabled, text, bp.textAttributesDisabled, width, height,align, hPad, vPad);
			}
		}
		
		override public function set name(n:String):void
		{
			_name = _sb.name = n;
		}
		
		override public function get name():String
		{
			return _name;
		}
		
		public function set enabled(e:Boolean):void
		{
			_sb.enabled = _sb.mouseEnabled = e;
			
			if (!e)
				_sb.upState = _disabled;
			else
				_sb.upState = _up;		
		}
		
		public function get enabled():Boolean
		{
			return _enabled;
		}
	}
}