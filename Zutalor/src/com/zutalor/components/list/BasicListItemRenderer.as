package com.zutalor.components.list
{
	import com.zutalor.components.button.Button;
	import com.zutalor.containers.Container;
	import com.zutalor.interfaces.IListItemRenderer;
	import com.zutalor.translate.Translate;
	/**
	 * ...
	 * @author Geoff
	 */
	public class BasicListItemRenderer implements IListItemRenderer
	{
		public function render(lp:ListProperties, c:Container):void
		{
			var data:Array;

			if (lp.url)
				loadData();
			else
			{
				data = lp.data.split(",");
			
				for (var i:int = 0; i < data.length; i++)
					c.push(createListItem(data[i]));
			}
			
			function createListItem(text:String):Button
			{
				var b:Button;
				
				b = new Button(text);
				b.vip.text = Translate.text(text);
				b.vip.presetId = lp.itemPresetId;
				b.render();
				return b;
			}
		}
		
		private function loadData():void
		{
			//TODO
		}
	}
}