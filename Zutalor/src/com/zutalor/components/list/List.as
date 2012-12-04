package com.zutalor.components.list 
{
	import com.zutalor.components.button.Button;
	import com.zutalor.components.Component;
	import com.zutalor.components.interfaces.IComponent;
	import com.zutalor.containers.ScrollingContainer;
	import com.zutalor.propertyManagers.PropertyManager;
	import com.zutalor.text.Translate;
	import com.zutalor.view.properties.ViewItemProperties;
	import com.zutalor.view.rendering.ViewLoader;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class List  extends Component implements IComponent
	{
		private static var _presets:PropertyManager;
		private var _scrollingContainer:ScrollingContainer;	
		private var _lp:ListProperties;
		
		public function List(name:String)
		{
			super(name);
		}
	
		public static function registerPresets(options:Object):void
		{	
			if (!_presets)
				_presets = new PropertyManager(ListProperties);
			
			_presets.parseXML(options.xml[options.nodeId]);
		}
			
		override public function render(viewItemProperties:ViewItemProperties = null):void
		{
			var viewLoader:ViewLoader;
			super.render(viewItemProperties);
			
			_lp = _presets.getPropsByName(vip.presetId);
			viewLoader = new ViewLoader();
			viewLoader.load(_lp.listView, null, populateList);
			visible = true;
			
			function populateList():void
			{
				var data:Array;
				_scrollingContainer = new ScrollingContainer("list");	
				addChild(_scrollingContainer);
				
				if (_lp.url)
					loadData();
				else
				{
					data = _lp.data.split(","); 
				
					for (var i:int = 0; i < data.length; i++)
						_scrollingContainer.push(createListItem(data[i]));
				}

				_scrollingContainer.autoArrangeContainerChildren( { padding:_lp.spacing, arrange:_lp.arrange } );
				_scrollingContainer.addEventListener(MouseEvent.CLICK, onTap, false, 0, true);
			}
		}
		
		private function loadData():void
		{
			//TODO
		}
		
		private function createListItem(text:String):Button
		{
			var b:Button;
			
			b = new Button(name);
			b.vip.text = Translate.text(text);
			b.vip.presetId = _lp.itemButtonId;
			b.vip.width = String(_lp.itemWidth);
			b.vip.height = String(_lp.itemHeight);
			b.render();
			return b;
		}
		
		private function onTap(me:MouseEvent):void
		{
			value = me.target.name;
			visible = !visible;
			
			trace(value);
		}
	}
}