package com.zutalor.components.list 
{
	import com.zutalor.components.button.Button;
	import com.zutalor.components.Component;
	import com.zutalor.components.interfaces.IComponent;
	import com.zutalor.containers.ScrollingContainer;
	import com.zutalor.propertyManagers.PropertyManager;
	import com.zutalor.text.Translate;
	import com.zutalor.view.controller.ViewController;
	import com.zutalor.view.properties.ViewItemProperties;
	import com.zutalor.view.rendering.ViewItemFilterApplier;
	import com.zutalor.view.rendering.ViewRenderer;
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
	
		public static function register(presets:XMLList):void
		{	
			if (!_presets)
				_presets = new PropertyManager(ListProperties);
			
			_presets.parseXML(presets);
		}
			
		override public function render(viewItemProperties:ViewItemProperties = null):void
		{
			super.render(viewItemProperties);
			
			var numItems:int;
			var itemIndex:int;
			var filters:Array = [];

			var filterApplier:ViewItemFilterApplier;
			var viewRenderer:ViewRenderer; 
			
			_lp = _presets.getPropsByName(vip.presetId);
			
			visible = true;
			
			filterApplier = new ViewItemFilterApplier(filters);
			viewRenderer = new ViewRenderer(this, itemRender, filterApplier.applyFilters);

			numItems = ViewController.views.getNumItems(_lp.listView);
			itemRender();
			
			function itemRender():void
			{
				var vip:ViewItemProperties;
			
				if (itemIndex < numItems)
				{
					vip = ViewController.views.getItemPropsByIndex(_lp.listView, itemIndex++);
					viewRenderer.renderItem(vip);	
				}	
				else
					onListRenderComplete();
			}
			
			function onListRenderComplete():void
			{
				var data:Array;
				var listItem:Button;
				
				_scrollingContainer = new ScrollingContainer("list");
				_scrollingContainer.addEventListener(MouseEvent.CLICK, onTap, false, 0, true);
				addChild(_scrollingContainer);
				data = _lp.dataProvider.split(",");
				
				for (var i:int = 0; i < data.length; i++)
				{
					listItem = createListItem(data[i]);
					_scrollingContainer.push(listItem);
				}
				_scrollingContainer.autoArrangeContainerChildren( { padding:_lp.spacing, arrange:_lp.arrange } );
			}
			
			function createListItem(text:String):Button
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
		}
		
		public function onTap(me:MouseEvent):void
		{
			value = me.target.name;
			visible = !visible;
			
			trace(value);
		}
	}
}