package com.zutalor.components.list 
{
	import com.zutalor.components.Component;
	import com.zutalor.components.interfaces.IComponent;
	import com.zutalor.containers.Container;
	import com.zutalor.containers.ScrollingContainer;
	import com.zutalor.containers.ViewContainer;
	import com.zutalor.events.UIEvent;
	import com.zutalor.propertyManagers.PropertyManager;
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
		
		private var _listContainer:Container;
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
			var numItems:int;
			var itemIndex:int;
			var width:int;
			var height:int;
			var filters:Array = [];

			var filterApplier:ViewItemFilterApplier;
			var viewRenderer:ViewRenderer; 
			
			_lp = _presets.getPropsByName(vip.presetId);
			
			visible = false;
			
			_listContainer.name = "list";
			_listContainer.visible = false;			
			addChild(_listContainer);
			
			filterApplier = new ViewItemFilterApplier(filters);
			viewRenderer = new ViewRenderer(_listContainer, onItemRenderCallBack, filterApplier.applyFilters);

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
					onRenderComplete();
			}
			
			function onRenderComplete():void
			{
				var data:Array;
				var listItem:ListItem;
				
				listItem = createListItem();
				_scrollingContainer = new ScrollingContainer("list");
				_scrollingContainer.addEventListener(MouseEvent.CLICK, onTap, false, 0, true);
				_listContainer.addChild(_listContainer);
				data = vip.text.split(",");
				
				for (var i:int = 0; i < data.length; i++)
				{
					var li:ListItem;
					
					li = listItem.clone();
					li.value = data[i];
					_scrollingContainer.push(li);
				}
				_scrollingContainer.autoArrangeContainerChildren( { padding:_lp.spacing, arrange:_lp.arrange } );
			}
			
			function createListItem():ListItem
			{
				var listItem:ListItem;
				
				listItem = new ListItem(vip.name);
				listItem.itemView = _lp.itemView;
				listItem.vip.width = String(width);
				listItem.vip.height = String(height);
				listItem.render();
				return listItem;
			}
		}
		
		public function onTap(me:MouseEvent):void
		{
			value = me.target.value;
			visible = !visible;
			
			trace(value);
		}
		
		public function load(items:Array):void
		{
			_scrollingContainer.autoArrangeContainerChildren( { padding:_lp.spacing, arrange:_lp.arrange } );
		}
	}
}