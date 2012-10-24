package com.zutalor.ui
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
					cpnt = getButton(componentId, text);
					break;
				case ViewItemProperties.SLIDER :
					cpnt = getSlider(componentId, text);
					break;
				case ViewItemProperties.TEXT_BUTTON :
					cpnt = getTextButton(componentId, text);
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
		
		public static function getButton(buttonId:String, text:String=null):Button
		{
			var bp:ButtonProperties;
			var b:Button;
			var width:int;
			var height:int;
			var align:String;
			var hPad:int;
			var vPad:int;
			var text:String;
			
			var up:*;
			var over:*;
			var down:*;
			var selected:*;
			var disabled:*;
			
			bp = Props.pr.buttonPresets.getPropsByName(buttonId);

			// ToDO throw errors
				
			b = new Button();
			
			if (bp.upGid)
			{
				up = new Graphic();
				up.render(bp.upGid);
			}	
			else 
				up = new Sprite();
			
			if (bp.overGid)
			{
				over = new Graphic();
				over.render(bp.overGid);
			}
			else
				over = new Sprite();

			if (bp.downGid)
			{
				down = new Graphic();
				down.render(bp.downGid);
			}
			else
				down = new Sprite();
				

			if (bp.selectedGid)
			{
				selected = new Graphic();
				selected.render(bp.selectedGid);
			}
			else
				selected = new Sprite();

			if (bp.disabledGid)
			{
				disabled = new Graphic();
				disabled.render(bp.disabledGid);
			}
			else
				disabled = new Sprite();
			
			b.create(up, over, down, selected, disabled);
							
			if (text)
			{
				if (!bp.width) 
				{
					width = b.up.width;
					height = b.up.height;
				}
				
				align = bp.align;
				hPad = bp.hPad;
				vPad = bp.vPad;

				if (!bp.textAttributesOver)
				{
					bp.textAttributesOver = bp.textAttributesSelected = bp.textAttributesDown = bp.textAttributesDisabled = bp.textAttributes;
				}
				TextUtil.add(b.up, text, bp.textAttributes, width, height, align, hPad, vPad); 
				TextUtil.add(b.over, text, bp.textAttributesOver, width, height, align, hPad, vPad);
				TextUtil.add(b.down, text, bp.textAttributesDown, width, height, align, hPad, vPad);
				TextUtil.add(b.disabled, text, bp.textAttributesDisabled, width, height,align, hPad, vPad);
				TextUtil.add(b.selected, text, bp.textAttributesSelected, width, height, align, hPad, vPad);
			}
			return b;
		}
		
		public static function getSlider(sliderId:String, text:String=null):Slider
		{
			var sp:SliderProperties = Props.pr.sliderPresets.getPropsByName(sliderId);
			var track:Button = Components.getButton(sp.trackButtonId);
			var thumb:Button = Components.getButton(sp.thumbButtonId, text);
			var reveal:Graphic;

			if (sp.revealGraphicId)
			{
				reveal = new Graphic();
				reveal.render(sp.revealGraphicId);
			}
			
			var slider:Slider = new Slider()
			slider.create(thumb, track, reveal, sp.vertical, sp.tweenTime, 
											sp.numSteps, sp.onlyShowTrackOnMouseDown);
			return slider;
		}
		
		public static function getTextButton(buttonId:String, text:String):TextButton
		{
			var bp:ButtonProperties = Props.pr.buttonPresets.getPropsByName(buttonId);
			var textButton:TextButton = new TextButton();
			textButton.create(text, int(bp.width), int(bp.height), false, 0, 
														bp.textAttributes, bp.textAttributesOver, bp.textAttributesDown, 
														bp.textAttributesSelected, bp.textAttributesDisabled, bp.textAttributesHeading);									
			return textButton;
		}
		
		public static function getToggle(toggleId:String, text:String):Toggle
		{
			var tp:ToggleProperties = Props.pr.togglePresets.getPropsByName(toggleId);
			var onButton:Button = Components.getButton(tp.onStateButtonId, text);
			var offButton:Button = Components.getButton(tp.offStateButtonId, text);
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