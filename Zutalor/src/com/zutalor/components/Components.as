package com.zutalor.components
{
	import com.zutalor.properties.ButtonProperties;
	import com.zutalor.properties.SliderProperties;
	import com.zutalor.properties.ToggleProperties;
	import com.zutalor.properties.ViewItemProperties;
	import com.zutalor.propertyManagers.Props;
	import com.zutalor.text.TextUtil;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Components
	{	
		public static var cpnt:*;
		
		public static function getComponent(name:String, type:String, componentId:String, text:String=null, dataProvider:String=null):*
		{			
			switch (type)
			{
				case ViewItemProperties.BUTTON :
					cpnt = new Button(componentId, text);
					break;
				case ViewItemProperties.SLIDER :
					cpnt = new Slider(componentId, text);
					break;
				case ViewItemProperties.TOGGLE :
					cpnt = getToggle(componentId, text);
					break;
				case ViewItemProperties.COMPONENT_GROUP :
					cpnt = getComponentGroup(componentId, dataProvider);
					break;
				case ViewItemProperties.RADIO_GROUP :
					cpnt = getRadioGroup(componentId, dataProvider);
					break;
				case ViewItemProperties.STEPPER :
					cpnt = getStepper(componentId);
					break;	
			}
			cpnt.name = name;
			return cpnt;
		}
		
		public static function getToggle(toggleId:String, text:String):Toggle
		{
			var tp:ToggleProperties = Props.pr.togglePresets.getPropsByName(toggleId);
			var onButton:Button = new Button(tp.onStateButtonId, text);
			var offButton:Button = new Button(tp.offStateButtonId, text);
			var toggle:Toggle = new Toggle();
			toggle.create(onButton, offButton);
			toggle.value = tp.initialValue;
			return toggle;
		}
		
		public static function getComponentGroup(cgId:String,dataProvider:String):ComponentGroup
		{
			var cg:ComponentGroup = new ComponentGroup();
			cg.create(cgId, dataProvider);
			return cg;
		}
		
		public static function getRadioGroup(id:String,dataProvider:String):RadioGroup
		{
			var rg:RadioGroup = new RadioGroup();
			rg.create(id, dataProvider);
			return rg;
		}		
		
		public static function getStepper(stepperId:String):Stepper
		{
			var stepper:Stepper = new Stepper();
			stepper.create(stepperId);
			return stepper;
		}
	}
}