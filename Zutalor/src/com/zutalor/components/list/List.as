package com.zutalor.components.list 
{
	import com.zutalor.components.button.Button;
	import com.zutalor.components.Component;
	import com.zutalor.components.interfaces.IComponent;
	import com.zutalor.containers.Container;
	import com.zutalor.containers.ScrollingContainer;
	import com.zutalor.propertyManagers.PropertyManager;
	import com.zutalor.view.controller.ViewController;
	import com.zutalor.view.properties.ViewItemProperties;
	import com.zutalor.view.rendering.ViewItemFilterApplier;
	import com.zutalor.view.rendering.ViewRenderer;
	import flash.display.SimpleButton;
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
			viewRenderer = new ViewRenderer(this, onItemRenderCallBack, filterApplier.applyFilters);

			numItems = ViewController.views.getNumItems(_lp.listView);
			onItemRenderCallBack();
			
			function onItemRenderCallBack():void
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
					listItem = createListItem();
					listItem.value = data[i];
					_scrollingContainer.push(listItem);
				}
				_scrollingContainer.autoArrangeContainerChildren( { padding:_lp.spacing, arrange:_lp.arrange } );
			}
			
			function createListItem():Button
			{
				var lib:Button;
				
				lib = new Button(name);
				lib.vip.tKey = vip.tKey;
				lib.vip.presetId = _lp.itemButtonId;
				lib.vip.width = String(_lp.itemWidth);
				lib.vip.height = String(_lp.itemHeight);
				lib.render();
				return lib;
			}
		}
		
		public function onTap(me:MouseEvent):void
		{
			var b:Button;
			b = _scrollingContainer.getChildByName(me.target.name) as Button;
			value = b.value;
			visible = !visible;
			
			trace(value);
		}
	}
}