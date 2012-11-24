package com.zutalor.components
{
	import com.zutalor.properties.ButtonProperties;
	import com.zutalor.properties.ViewItemProperties;
	import com.zutalor.propertyManagers.PropertyManager;
	import flash.display.SimpleButton;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Button extends Component implements IComponent
	{
		private var _sb:SimpleButton;
		private var _up:Graphic;
		private var _over:Graphic;
		private var _down:Graphic;
		private var _disabled:Graphic;
		private var _name:String;
		private var _vip:ViewItemProperties;
		
		public static function register(presets:XMLList):void
		{	
			if (!_presets)
				_presets = new PropertyManager(ButtonProperties);
			
			_presets.parseXML(presets);
			
			_vip = new ViewItemProperties();
		}
		
		override public function render(vip:ViewItemProperties):void
		{
			var bp:ButtonProperties;
			var width:int;
			var height:int;
			var align:String;
			var hPad:int;
			var vPad:int;
			var text:String;
			
			bp = ButtonProperties(presets.getPropsByName(vip.presetId));
			
			_up = new Graphic();
			_vip.graphicId = bp.upGid;
			_up.render(_vip);
	
			_over = new Graphic();
			_vip.graphicId = bp.overGid;
			_over.render(_vip);

			_down = new Graphic();
			_vip.graphicId = bp.downGid;
			_down.render(_vip);

			_disabled = new Graphic();
			
			if (bp.disabledGid)
				_vip.graphicId = bp.disabledGid;
			else
				_vip.graphicId = bp.upGid;
			
			_disabled.render(_vip);	
				
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
				
				Label.addLabel(_up, text, bp.textAttributes, width, height, align, hPad, vPad); 
				Label.addLabel(_over, text, bp.textAttributes, width, height, align, hPad, vPad);
				Label.addLabel(_down, text, bp.textAttributesDown, width, height, align, hPad, vPad);
				Label.addLabel(_disabled, text, bp.textAttributesDisabled, width, height,align, hPad, vPad);
			}
		}
		
		override public function set enabled(value:Boolean):void
		{
			super.enabled = value;
			_sb.enabled = _sb.mouseEnabled = value;
			
			if (!value)
				_sb.upState = _disabled;
			else
				_sb.upState = _up;		
		}
	}
}