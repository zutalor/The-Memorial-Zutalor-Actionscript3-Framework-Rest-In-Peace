package com.zutalor.components.list 
{
	import com.zutalor.components.Component;
	import com.zutalor.components.graphic.Graphic;
	import com.zutalor.components.label.Label;
	import com.zutalor.view.controller.ViewController;
	import com.zutalor.view.properties.ViewItemProperties;
	import com.zutalor.view.rendering.ViewItemFilterApplier;
	import com.zutalor.view.rendering.ViewItemPositioner;
	import com.zutalor.view.rendering.ViewRenderer;
	/**
	 * ...
	 * @author Geoff
	 */
	public class ListItem extends Component implements Component
	{
		public var background:Graphic;
		public var rightIcon:Graphic;
		public var leftIcon:Graphic;
		public var label:Label;
		
		private var _filters:Array;
		
		public static function register(presets:XMLList):void
		{	
			if (!_presets)
				_presets = new PropertyManager(ListProperties);
			
			_presets.parseXML(presets);
		}	
		
		override public function render(viewItemProperties:ViewItemProperties = null):void
		{
			super(viewItemProperties);
			
			var filterApplier:ViewItemFilterApplier;
			var itemPositioner:ViewItemPositioner;
			var viewRenderer:ViewRenderer;
			
			var lp:ListProperties;
			var vip:ViewItemProperties;

			var itemIndex:int;
			var numViewItems:int;
		
			_filters = [];
			filterApplier = new ViewItemFilterApplier();
			itemPositioner = new ViewItemPositioner(
			
			lp = _presets(vip.presetId);
			viewRenderer = new ViewRenderer(c, onItemRenderCallBack, new ViewItemFilterApplier(_filters),
			
			
																		);
			numItems = ViewController.views.getNumItems(vip.presetId);
			onItemRenderCallBack();
			
			function onItemRenderCallBack():void
			{
				var vip:ViewItemProperties;
			
				if (itemIndex < numViewItems)
				{
					vip = views.getItemPropsByIndex(lp.listView, itemIndex++);
					viewRenderer.renderItem(vip);
				}	
			}	
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