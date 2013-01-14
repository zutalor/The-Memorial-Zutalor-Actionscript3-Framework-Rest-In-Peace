package com.zutalor.view.controller
{
	import com.greensock.TweenMax;
	import com.gskinner.utils.IDisposable;
	import com.zutalor.components.base.Component;
	import com.zutalor.containers.base.ContainerObject;
	import com.zutalor.containers.ViewContainer;
	import com.zutalor.events.HotKeyEvent;
	import com.zutalor.events.UIEvent;
	import com.zutalor.interfaces.IMediaPlayer;
	import com.zutalor.plugin.constants.PluginMethods;
	import com.zutalor.plugin.Plugins;
	import com.zutalor.positioning.Dragger;
	import com.zutalor.properties.NestedPropsManager;
	import com.zutalor.utils.gDictionary;
	import com.zutalor.utils.ShowError;
	import com.zutalor.view.mediators.ViewEventMediator;
	import com.zutalor.view.mediators.ViewModelMediator;
	import com.zutalor.view.properties.ViewItemProperties;
	import com.zutalor.view.properties.ViewProperties;
	import com.zutalor.view.rendering.ViewItemFilterApplier;
	import com.zutalor.view.rendering.ViewItemPositioner;
	import com.zutalor.view.rendering.ViewRenderer;
	import com.zutalor.view.transition.ItemFX;
	import com.zutalor.widgets.Focus;
	import flash.geom.Point;

	public class ViewController implements IDisposable
	{		
		private var onComplete:Function;
		private var viewRenderer:ViewRenderer;
		private var defaultVO:*;
	
		public var filters:Array;	
		public var viewEventMediator:ViewEventMediator;
		public var viewItemPositioner:ViewItemPositioner;
		public var viewId:String;
		public var numViewItems:int;		
		public var vp:ViewProperties;	
		public var itemWithFocus:Component;
		public var itemWithFocusIndex:int;		
		public var onStatus:Function;		
		public var viewModelMediator:ViewModelMediator;
		public var dragger:Dragger;
		public var draggableDict:gDictionary;
		
		private static var _presets:NestedPropsManager;
		
		public function ViewController() {}
				
		public static function registerPresets(options:Object):void
		{
			if (!_presets)
				_presets = new NestedPropsManager();
			
			_presets.parseXML(ViewProperties, ViewItemProperties, options.xml[options.nodeId], options.childNodeId, 
																				options.xml[options.childNodeId]);
		}
		
		public static function get presets():NestedPropsManager
		{
			return _presets;
		}
	
		public function load(vc:ViewContainer, pViewId:String, appState:String, pOnComplete:Function):void
		{	
			viewId = pViewId;
			onComplete = pOnComplete;
			vp = presets.getPropsById(viewId);
			filters = [];		

			if (!vp)
				ShowError.fail(ViewController,"No view properties for viewId: " + viewId);
			
			vp.appState = appState;
			ViewControllerRegistry.registerController(viewId, this);
			vp.container = vc;
			vp.container.viewController = this;

			if (vp.uiControllerInstanceName)
			{
				Plugins.callMethod(vp.uiControllerInstanceName, PluginMethods.INIT, { controller:this, id:viewId } );
				defaultVO = Plugins.callMethod(vp.uiControllerInstanceName, PluginMethods.GET_VALUE_OBJECT);
				viewModelMediator = new ViewModelMediator(this);
			}
			
			numViewItems = presets.getNumItems(viewId);	
			viewEventMediator = new ViewEventMediator(this);
			viewItemPositioner = new ViewItemPositioner(vp.container, vp.width, vp.height);
			viewRenderer = new ViewRenderer(this);
			viewRenderer.render(onRenderComplete);
		}
		
		protected function onRenderComplete():void
		{
			viewRenderer.dispose();
			viewRenderer = null;
			onComplete();
		}
		
		// PUBLIC METHODS
			
		public function get container():ViewContainer
		{
			return vp.container;
		}
					
		public function positionAllItems():void
		{
			for (var i:int; i < numViewItems; i++)
				viewItemPositioner.positionItem(presets.getItemPropsByIndex(viewId, i));
		}
		
		public function callUiControllerMethod(method:String, arg:*, controllerId:String = null):void
		{
			if (!controllerId)
				controllerId = vp.uiControllerInstanceName;
			
			Plugins.callMethod(controllerId, method, arg);
		}
		
		public function setModelValue(itemName:String, val:*):void
		{
			if (defaultVO)
			{	
				defaultVO[itemName] = val;
				copyModelToView(itemName);
			}
		}
		
		public function getModelValue(itemName:String):*
		{
			if (defaultVO)
				return defaultVO[itemName];
		}
			
		public function setItemWithFocus(itemName:String):void
		{
			if (itemName)
			{
				itemWithFocus = getItemByName(itemName);
				itemWithFocusIndex = getItemIndexByName(itemName);
				Focus.show(itemWithFocus, vp.container);
			}
			else	
			{
				itemWithFocus = getItemByIndex(0);
				itemWithFocusIndex = 0;
				viewEventMediator.validateSelection(new HotKeyEvent(HotKeyEvent.HOTKEY_PRESS, "down"));
			}
			viewEventMediator.onItemFocusIn();
		}
		
		public function onModelChange(itemNames:String = null):void
		{
			var items:Array
			
			if (itemNames)
			{
				items = itemNames.split(",");
				for (var i:int = 0; i < items.length; i++)
					copyModelToView(items[i]);
			}
			else
				copyModelToView();
		}
		
		public function onViewChange(itemNames:String = null):void
		{
			var items:Array

			if (itemNames)
			{
				items = itemNames.split(",");
				for (var i:int = 0; i < items.length; i++)
					copyViewToModel(items[i]);
			}
			else
				copyViewToModel();
		}
		
		private function copyViewToModel(itemName:String = null):void
		{
			var vip:ViewItemProperties;
			var item:Component;
			
			if (itemName)
			{
				vip = presets.getItemPropsByName(viewId, itemName);
			
				if (vip.voName)
				{
					Plugins.callMethod(vp.uiControllerInstanceName, PluginMethods.VALUE_UPDATED, { itemName:vip.name, voName:vip.voName } );
					item = vp.container.getChildByName(itemName) as Component;
					viewModelMediator.copyViewItemToValueObject(vip, item);
				}
				else
					ShowError.fail(ViewController,"invalid item name " + itemName + " for view: " + viewId);
			}
			else
				for (var i:int = 0; i < numViewItems; i++) 
				{
					vip = presets.getItemPropsByIndex(viewId, i);
					if (vip.voName)
					{
						Plugins.callMethod(vp.uiControllerInstanceName, PluginMethods.VALUE_UPDATED, { itemName:vip.name, voName:vip.voName } );
						item = vp.container.getChildAt(i) as Component;
						viewModelMediator.copyViewItemToValueObject(vip, item);
					}
				}
		}
		
		private function copyModelToView(itemName:String=null):void
		{
			var vip:ViewItemProperties;
			var item:Component;

			if (itemName)
			{
				vip = presets.getItemPropsByName(viewId, itemName);
				if (vip.voName)
				{
					item = vp.container.getChildByName(itemName) as Component;
					viewModelMediator.copyValueObjectToViewItem(vip, item);
				}
				else
					ShowError.fail(ViewController, "Invalid item name " + itemName + " for view: " + viewId);
			}
			else
				for (var i:int = 0; i < numViewItems; i++) 
				{
					vip = presets.getItemPropsByIndex(viewId, i);
					if (vip.voName)
					{
						item = vp.container.getChildAt(i) as Component;
						viewModelMediator.copyValueObjectToViewItem(vip, item);
					}
				}
		}	
		
		public function setStatus(s:String):void
		{
			if (onStatus != null)
				onStatus(s);
		}
		
		public function onModelError(responds:Object=null):void
		{
			setStatus(String(responds));
		}		
		
		// PUBLIC STOP & CLEANUP (WHEN VIEW CONTAINER IS CLOSED) 
				
		public function stop(fadeSeconds:Number = 0):void
		{
			var item:Component;
			
			for (var i:int = 0; i < numViewItems; i++)
			{
				item = vp.container.getChildAt(i) as Component;
				if (item is IMediaPlayer)
				{
					item.stop(fadeSeconds);
				}
			}
		}
		
		public function dispose():void
		{
			var i:int;
			var numFilters:int;
			var l:int;
			
			if (dragger)
			{
				dragger.dispose()
				draggableDict.dispose();
				dragger = null;
				draggableDict = null;
			}
			ViewControllerRegistry.unregisterController(viewId);
			
			viewEventMediator.itemListenerCleanup();
			viewEventMediator.removeListenersFromContainer(container);
			
			if (filters)
			{
				numFilters = filters.length;
				for (i = 0; i < numFilters; i++)
					filters[i].dispose();
			}
			vp.container.dispose();
			filters = null;
			numViewItems = 0;
			viewModelMediator = null;
			viewEventMediator = null;		
			Plugins.callMethod(vp.uiControllerInstanceName, PluginMethods.DISPOSE)			
		}
		
		// GET THE UI ITEM's OBJECT OR PROPERTIES
		
		public function getItemByIndex(indx:int):Component
		{
			return vp.container.getChildAt(indx) as Component;
		}
		
		public function getItemIndexByName(name:String):int
		{
			return vp.container.getChildIndex(vp.container.getChildByName(name));
		}
		
		public function getItemByName(itemName:String):Component
		{
			var vip:ViewItemProperties;
			var item:Component;
			
			vip = presets.getItemPropsByName(viewId, itemName);
			if (vip && vp.container.numChildren)
				item = vp.container.getChildByName(itemName) as Component;

			return item;
		}
		
		public function getItemPropsByName(itemName:String):ViewItemProperties
		{
			return presets.getItemPropsByName(viewId, itemName);
		}
		
		public function getItemPropsByIndex(index:int):ViewItemProperties
		{
			return presets.getItemPropsByIndex(viewId, index);
		}
		
		
		// VIEW DISPLAY RELATED METHODS
		
		public function setItemAlpha(itemName:String, a:Number):void		
		{
			var vip:ViewItemProperties;
			var item:Component;
			
			vip = presets.getItemPropsByName(viewId, itemName);
			if (vip && vp.container.numChildren)
				item = vp.container.getChildByName(itemName) as Component;
				if (item)
					item.alpha = a;
		}
		
		public function setItemVisibility(name:String, visible:Boolean = true, fade:int = 0, delay:int = 0):void
		{
			ItemFX.fade(vp.name, vp.container.getChildByName(name), visible, fade, delay);
		}
		
		public function setEnabled(itemName:String, d:Boolean):void
		{
			var item:Component;
			
			item = vp.container.getChildByName(itemName) as Component;
			if (item)
			{
				if(item.hasOwnProperty("enabled"))
					item.enabled = d;
			}
		}
		
		public function getEnabled(itemName:String):Boolean
		{
			var item:Component;
			
			item = getItemByName(itemName); 
			if (item.alpha == 0 || item.visible == false)
				item.enabled = false;
			
			return item.enabled;
		}
		
		public function hide(useTransition:Boolean=true):void
		{
			if (useTransition)
				TweenMax.to(vp.container, 1, { alpha:0, visible:false } );
			else
				vp.container.visible = false;
		}
		
		public function show(useTransition:Boolean=true):void
		{
			if (useTransition)
			{
				vp.container.visible = true;
				vp.container.alpha = 0;
				TweenMax.to(vp.container, 1, { alpha:1 } );
			}
			else
			{
				vp.container.alpha = 1;
				vp.container.visible = true;
			}
		}
				
		//EVENT DISPATCH
		
		public function dispatchStateSelection(ms:String):void
		{
			vp.container.dispatchEvent(new UIEvent(UIEvent.APP_STATE_SELECTED, vp.container.name, ms));
		}
		
		public function dispatchUiEvent(eventType:String):void
		{
			vp.container.dispatchEvent(new UIEvent(eventType, vp.container.name));
		}				

		public function registerDraggableObject(co:ContainerObject):void
		{
			if (!dragger)
			{
				dragger = new Dragger(vp.container, onPositionUpdate);
				draggableDict = new gDictionary();
				dragger.initialize(vp.width, vp.height, vp.width, vp.height);
			}	
			draggableDict.insert(co, true);
		}
		
		private function onPositionUpdate(p:Point, co:*):void
		{
			if (draggableDict.getByKey(co))
			{
				co.x  = p.x;
				co.y  = p.y;
			}
		}
	}
}
