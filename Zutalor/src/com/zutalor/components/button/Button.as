package com.zutalor.components.button
{
	import com.zutalor.components.Component;
	import com.zutalor.components.graphic.Graphic;
	import com.zutalor.components.interfaces.IComponent;
	import com.zutalor.components.label.Label;
		import com.zutalor.view.properties.ViewItemProperties;
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
		
		public static function register(presets:XMLList):void
		{	
			if (!_presets)
				_presets = new PropertyManager(ButtonProperties);
			
			_presets.parseXML(presets);
		}
		
		override public function render(viewItemProperties:ViewItemProperties = null):void
		{
			var width:Number;
			var height:Number;
			var bp:ButtonProperties;
			var buttonStates:Array = [_up, _over, _down, _disabled];
			
			super.render(viewItemProperties);
			
			bp = ButtonProperties(presets.getPropsByName(vip.presetId));
			
			_up = new Graphic();
			this.vip.presetId = bp.upId;
			_up.render(vip);
	
			_over = new Graphic();
			vip.presetId = bp.overId;
			_over.render(vip);

			_down = new Graphic();
			vip.presetId = bp.downId;
			_down.render(vip);

			_disabled = new Graphic();
			
			if (bp.disabledId)
				vip.presetId = bp.disabledId;
			else
				vip.presetId = bp.upId;
			
			_disabled.render(vip);	
				
			_sb = new SimpleButton(_up, _over, _down, _up);
			this.addChild(_sb);
							
			if (vip.text)
			{
				if (!bp.width) 
				{
					width = _up.width;
					height = _up.height;	
				}
				else
				{
					width = bp.width;
					height = bp.height;
				}
				
				vip.hPad = bp.hPad;
				vip.vPad = bp.vPad;

				if (!bp.textAttributesDown)
				{
					bp.textAttributesDown = bp.textAttributesDisabled = bp.textAttributes;
				}
				
				vip.textAttributes = bp.textAttributes;

				for (var i:int = 0; i < buttonStates.length; i++)
				{
					var label:Label;
					label = new Label();
					vip.align = bp.align;
					vip.hPad = bp.hPad;
					vip.vPad = bp.vPad;
					label.render(vip);
					label.name = name;
					buttonStates[i].addChild(label);
				}
			}
		}
		
		override public function set name(n:String):void
		{
			for (var i:int; i < numChildren; i++)
				getChildAt(i).name = n;
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