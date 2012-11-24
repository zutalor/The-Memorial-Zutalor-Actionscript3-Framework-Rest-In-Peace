package com.zutalor.components
{
	import com.zutalor.events.UIEvent;
	import com.zutalor.plugin.Plugins;
	import com.zutalor.properties.ComponentGroupProperties;
	import com.zutalor.properties.ViewItemProperties;
	import com.zutalor.propertyManagers.PropertyManager;
	import com.zutalor.utils.ShowError;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ComponentGroup extends Component implements IComponent
	{
		protected var gp:ComponentGroupProperties;
		protected var values:Array;
		public var contentContainer:Sprite;
		
		protected var numHaveValue:int;
		
		// there is so much more fun to be had with this class!!!! Here comes a DJ mixer with button, slider, lights, or whatever arrays!

		public static function register(preset:XMLList):void
		{	
			if (!_presets)
				_presets = new PropertyManager(ComponentGroupProperties);
			
			_presets.parseXML(preset);
		}
		
		public static function get presets():PropertyManager
		{
			return _presets;
		}
		
		override public function render(vip:ViewItemProperties):void
		{
			var x:int;
			var y:int;
			var row:int;
			var col:int;
			var item:*;			
			var inits:Array;
			var componentId:String;
			var componentIds:Array;
			var viewItemTypes:Array;
			var componentType:String;
			this.name = name;
			
			gp = _presets.getPropsByName(vip.presetId);
			contentContainer = new Sprite();
			addChild(contentContainer);

			values = [];
			if (vip.text)
				inits = vip.text.split(",");

			if (!gp.componentIds)
				ShowError.fail(ComponentGroup,"Component Group: no component Ids to render.");
			
			if (!gp.viewItemTypes)
				ShowError.fail(ComponentGroup,"Component Group: need at least one component type."); 

			componentIds = gp.componentIds.split(",");
			viewItemTypes = gp.viewItemTypes.split(",");		
			
			if (!gp.numComponents)
				gp.numComponents = componentIds.length;	
			
			if (!gp.numCols)
				gp.numCols = gp.numComponents;
				
			if (!gp.maxHaveValue)
				gp.maxHaveValue = gp.numComponents;

			for (var i:int = 0; i < gp.numComponents; i++)
			{
				if (i < componentIds.length)
					componentId = componentIds[i];
				
				if (i < viewItemTypes.length)
					componentType = viewItemTypes[i];
				
				item = Plugins.getClass(componentType);
				contentContainer.addChild(item);
				
				item.x = x;
				item.y = y;
				item.name = componentIds[i];
				col++
				if (col < gp.numCols)
				{
					x += item.width + gp.hPad;
				}
				else
				{
					col = 0;
					x = 0;
					y += item.height + gp.vPad;
				}				
			
				if (inits)
					if (i < inits.length)
						item.value = inits[i];
			}					
			contentContainer.addEventListener(UIEvent.VALUE_CHANGED, onValueChange, false, 0, true);
		}
		
		override public function onValueChange(uie:UIEvent):void
		{
			var indx:int;
			var val:*;
			
			indx = contentContainer.getChildIndex(DisplayObject(uie.target));
			val = uie.target.value;
			
			if (val != values[indx])
			{
				if (!val)
				{
					if (numHaveValue > gp.minHaveValue)
					{
						if (numHaveValue)
							numHaveValue--
					}
					else
						val = values[indx];
				}
				else
				{
					if (numHaveValue < gp.maxHaveValue)
						numHaveValue++;
					else
						for (var i:int = 0; i < gp.numComponents; i++)
							if (values[i] && i != indx)
							{
								values[i] = null;
								break;
							}
				}
			}
			values[indx] = val;
			dispatchEvent(new UIEvent(UIEvent.VALUE_CHANGED, null, null, name, values));						
		}
		
		override public function set value(v:*):void
		{
			values = v;
			numHaveValue = 0;
			for (var i:int = 0; i < gp.numComponents; i++)
			{
				if (values[i])
					numHaveValue++;
					
				Object(contentContainer.getChildAt(i)).value = values[i]; // maybe cache values in case this is too expensive time wise
			}			
		}
		
		override public function get value():*
		{
			return values;
		}
		
		override public function dispose():void
		{
			// todo
		}
	}
}