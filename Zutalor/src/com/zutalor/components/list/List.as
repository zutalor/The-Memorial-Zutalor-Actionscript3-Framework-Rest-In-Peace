package com.zutalor.components.list 
{
	import com.zutalor.components.Component;
	import com.zutalor.components.interfaces.IComponent;
	import com.zutalor.containers.Container;
	import com.zutalor.containers.ScrollingContainer;
	import com.zutalor.containers.ViewContainer;
	import com.zutalor.events.UIEvent;
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
		private static const LIST_STATE_CLOSED = "closed";
		private static const LIST_STATE_OPEN = "open";
		
		private var _state:String;
		private var _closedStateComponent:Component;
		private var _listContainer:Container;
		private var _scrollingContainer:ScrollingContainer;		
		
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
			var lp:ListProperties;
			var filterApplier:ViewItemFilterApplier;
			var viewRenderer:ViewRenderer; 
			var CloseStateClass:Class;
			
			lp = _presets.getPropsByName(vip.presetId);
			
			CloseStateClass = Plugins.getClass(lp.closedStateType);
			closedStateComponent = new CloseStateClass();
			closedStateComponent.vip.presetId = lp.closedStatePresetId;
			closedStateComponent.x = vip.x;
			closedStateComponent.y = vip.y;
			addChild(closedStateComponent);
			closedStateComponent.addEventListener(MouseEvent.CLICK, onTap, false, 0, true);
			_state = LIST_STATE_CLOSED;
			
			_listContainer = new Container("list", vip.width, vip.height);
			addChild(_listContainer);
			_listContainer.visible = false;
			
			filterApplier = new ViewItemFilterApplier(filters);
			viewRenderer = new ViewRenderer(_listContainer, onItemRenderCallBack, filterApplier);

			numItems = ViewController.views.getNumItems(lp.listView);
			onItemRenderCallBack();
			
			function onItemRenderCallBack():void
			{
				var vip:ViewItemProperties;
			
				if (itemIndex < numItems)
				{
					vip = ViewController.views.getItemPropsByIndex(viewId, itemIndex++);
					_viewRenderer.renderItem(vip);	
				}	
				else
					onRenderComplete();
			}
			
			function onRenderComplete():void
			{
				var data:Array;
				var listItem:ListItem;
				
				listItem = createListItem();
				_scrollingContainer = new ScrollingContainer("list", vip.width, vip.height);
				_scrollingContainer.addEventListener(MouseEvent.CLICK, onTap, false, 0, true);
				_listContainer.addChild(_listContainer);
				data = vip.text.split(",");
				
				for (var i:int = 0; i < data.length; i++)
				{
					var li:ListItem;
					
					li = listItem.clone();
					li.label.value = data[i];
					_scrollingContainer.push(li);
				}
				_scrollingContainer.autoArrangeContainerChildren( { padding:lp.padding, arrange:"vertical" } );
			}
			
			function createListItem():ListItem
			{
				var listItem:ListItem;
				
				listItem = new ListItem();
				listItem.itemView = lp.itemView;
				listItem.vip.width = width;
				listItem.vip.height = height;
				listItem.render();				
			}
		}
		
		public function onTap(me:MouseEvent):void
		{
			var indx:int;
			
			if (_listContainer.visible)
				value = me.target.value;
				
			_closedStateComponent.visible = !_closedStateComponent.visible;
			_listContainer.visible = !_listContainer.visible;
			
			trace(value);
		}
		
		public function load(items:Array):void
		{
			scrollingContainer.autoArrangeContainerChildren( { padding:lp.padding, arrange:"vertical" } );
		}
				
		
		override public function dispatchValueChange(uie:UIEvent):void
		{
			dispatchEvent(uie.clone());
		}
		
		override public function set value(value:*):void
		{
			_closedStateComponent.value = super.value v;
			// todo highlight and scroll to the proper value.
		}
	}
		
	}

}