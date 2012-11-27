package com.zutalor.components.list 
{
	import com.zutalor.components.Component;
	import com.zutalor.components.interfaces.IComponent;
	import com.zutalor.containers.Container;
	import com.zutalor.containers.ViewContainer;
	import com.zutalor.events.UIEvent;
	import com.zutalor.view.controller.ViewController;
	import com.zutalor.view.properties.ViewItemProperties;
	import com.zutalor.view.rendering.ViewItemFilterApplier;
	import com.zutalor.view.rendering.ViewRenderer;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class List  extends Component implements IComponent
	{
		
	
		
		override public function render(viewItemProperties:ViewItemProperties = null):void
		{
			var _numItems:int;
			var filters:Array = [];
			var listItem:Container = new Container("list", vip.width, vip.height);
			var viewRenderer:ViewRenderer = new ViewRenderer(c, onItemRenderCallBack, new ViewItemFilterApplier(filters));
			
			_numItems = ViewController.views.getNumItems(vip.presetId);
			onItemRenderCallBack();
			
			function onItemRenderCallBack():void
			{
				var vip:ViewItemProperties;
			
				if (_itemIndex < _numViewItems)
				{
					vip = views.getItemPropsByIndex(_viewId, _itemIndex++);
					_viewRenderer.renderItem(vip);
				}	
			}
		}
				
		override public function onValueChange(uie:UIEvent):void
		{
			
		}
		
		override public function dispatchValueChange(uie:UIEvent):void
		{
			dispatchEvent(uie.clone());
		}
		
		override public function get value():*
		{
			return null;
		}
		
		override public function set value(value:*):void
		{
			
		}
	}
		
	}

}