package com.zutalor.components
{
	import com.gskinner.utils.IDisposable;
	import com.zutalor.events.UIEvent;
	import com.zutalor.properties.ComponentGroupProperties;
	import com.zutalor.propertyManagers.Props;
	import com.zutalor.utils.ArrayUtils;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class RadioGroup extends ComponentGroup implements IDisposable
	{
		
		public function RadioGroup(groupId:String, dataProvider:String)
		{
			super.init(groupId, dataProvider);
		}
		
		public function get radioIndex():int
		{
			return ArrayUtils.getIndexWithValue(values);
		}
		
		public function set radioIndex(indx:int):void
		{
			for (var i:int = 0; i < gp.numComponents; i++)
				if (values[i] && i != indx)
				{
					values[i] = null;
					break;
				}			
				
			values[indx] = true;
			dispatchEvent(new UIEvent(UIEvent.VALUE_CHANGED, null, null, name, values));						
		}
		
		public function get numButtons():int
		{
			return gp.numComponents;
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
					if (numHaveValue > 1)
					{
						if (numHaveValue)
							numHaveValue--
					}
					else
						val = values[indx];
				}
				else
				{
					if (numHaveValue < 1)
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
	}
}