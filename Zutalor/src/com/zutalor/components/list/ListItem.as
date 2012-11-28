package com.zutalor.components.list 
{
	import com.zutalor.components.Component;
	import com.zutalor.components.graphic.Graphic;
	import com.zutalor.components.interfaces.IComponent;
	import com.zutalor.components.interfaces.IListItemComponent;
	import com.zutalor.components.label.Label;
	import com.zutalor.utils.ObjectUtil;
	import com.zutalor.view.controller.ViewController;
	import com.zutalor.view.properties.ViewItemProperties;
	import com.zutalor.view.rendering.ViewItemFilterApplier;
	import com.zutalor.view.rendering.ViewItemPositioner;
	import com.zutalor.view.rendering.ViewRenderer;
	/**
	 * ...
	 * @author Geoff
	 */
	public class ListItem extends Component implements IComponent
	{
		public var itemView:String;
		public var background:Graphic;
		public var rightIcon:Graphic;
		public var leftIcon:Graphic;
		public var label:Label;
		
		private var _filters:Array;
		
		override public function render(viewItemProperties:ViewItemProperties = null):void
		{
			super(viewItemProperties);
			
			var filterApplier:ViewItemFilterApplier;
			var itemPositioner:ViewItemPositioner;
			var viewRenderer:ViewRenderer;			
			var itemIndex:int;
			var numViewItems:int;
		
			_filters = [];
			filterApplier = new ViewItemFilterApplier();
			itemPositioner = new ViewItemPositioner(this, vip.width, vip.height);
			
			viewRenderer = new ViewRenderer(this, onItemRenderCallBack, new ViewItemFilterApplier(_filters), itemPositioner);
			
			numViewItems = ViewController.views.getNumItems(itemView);
			onItemRenderCallBack();
			
			function onItemRenderCallBack():void
			{
				var vip:ViewItemProperties;
				
				if (itemIndex < numViewItems)
				{
					vip = views.getItemPropsByIndex(itemView, itemIndex++);
					viewRenderer.renderItem(vip);
				}	
			}	
		}
		
		public function clone():ListItem
		{
			return ObjectUtil.clone(this) as ListItem;
		}
		
		override public function dispose():void
		{
			super.dispose();
			_filters = null;
		}
		
		override public function get value():*
		{
			if (label)
				return label.value;
			else
				return null;
		}
		
		override public function set value(v:*):void
		{
			if (label)
				label.value = v;
		}
	}
}