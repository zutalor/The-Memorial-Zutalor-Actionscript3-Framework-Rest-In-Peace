package com.zutalor.components
{
	import com.gskinner.utils.IDisposable;
	import com.zutalor.events.UIEvent;
	import com.zutalor.properties.ComponentGroupProperties;
	import com.zutalor.propertyManagers.Props;
	import com.zutalor.utils.ArrayUtils;
	import com.zutalor.utils.ShowError;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ComponentGroup extends Sprite implements IDisposable
	{
		protected var gp:ComponentGroupProperties;
		protected var values:Array;
		public var contentContainer:Sprite;
		
		protected var numHaveValue:int;
		
		public function ComponentGroup() 
		{
			// there is so much more fun to be had with this class!!!! Here comes a DJ mixer with button, slider, lights, or whatever arrays!
		}
		
		public function create(groupId:String, dataProvider:String):void
		{
			var x:int;
			var y:int;
			var row:int;
			var col:int;
			var item:*;			
			var inits:Array;
			var componentId:String;
			var componentIds:Array;
			var componentTypes:Array;
			var componentType:String;
			this.name = name;
			
			gp = Props.pr.componentGroupPresets.getPropsByName(groupId);
			contentContainer = new Sprite();
			addChild(contentContainer);

			values = [];
			if (dataProvider)
				inits = dataProvider.split(",");

			if (!gp.componentIds)
				ShowError.fail(ComponentGroup,"Component Group: no component Ids to render.");
			
			if (!gp.componentTypes)
				ShowError.fail(ComponentGroup,"Component Group: need at least one component type."); 

			componentIds = gp.componentIds.split(",");
			componentTypes = gp.componentTypes.split(",");		
			
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
				
				if (i < componentTypes.length)
					componentType = componentTypes[i];
				
				item = Components.getComponent(name, componentType, componentId);
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
		
		protected function onValueChange(uie:UIEvent):void
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
		
		public function set value(v:Array):void
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
		
		public function get value():*
		{
			return values;
		}
		
		public function dispose():void
		{
			// todo
		}
	}
}