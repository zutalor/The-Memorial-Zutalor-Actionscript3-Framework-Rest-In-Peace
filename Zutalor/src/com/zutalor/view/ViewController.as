package com.zutalor.view
{
	import com.greensock.TweenMax;
	import com.gskinner.utils.IDisposable;
	import com.zutalor.containers.ViewContainer;
	import com.zutalor.events.HotKeyEvent;
	import com.zutalor.events.UIEvent;
	import com.zutalor.fx.TransitionTypes;
	import com.zutalor.interfaces.IMediaPlayer;
	import com.zutalor.objectPool.ObjectPool;
	import com.zutalor.plugin.constants.PluginMethods;
	import com.zutalor.plugin.Plugins;
	import com.zutalor.properties.ApplicationProperties;
	import com.zutalor.properties.ViewItemProperties;
	import com.zutalor.properties.ViewProperties;
	import com.zutalor.propertyManagers.NestedPropsManager;
	import com.zutalor.propertyManagers.Props;
	import com.zutalor.text.TextUtil;
	import com.zutalor.text.Translate;
	import com.zutalor.ui.Focus;
	import com.zutalor.utils.gDictionary;
	import flash.events.Event;

	public class ViewController implements IDisposable
	{	
		public static const READING:String = "readingMessage";
		public static const CREATING:String = "creatingMessage";
		public static const DELETING:String = "deletingMessage";
		public static const UPDATING:String = "updatingMessage";
		public static const SUCCESS:String = "successMessage";
		public static const ERROR:String = "errorMessage";
		
		private	var _ap:ApplicationProperties;
		private var _onComplete:Function;
		private var _itemIndex:int;
		private var _viewEvents:ViewEvents;
		private var _container:ViewContainer;
		private var _defaultVO:*;
		
		public var successMessage:String;
		public var errorMessage:String;
		public var creatingMessage:String;
		public var readingMessage:String;
		public var deletingMessage:String;
		public var updatingMessage:String;
		
		public var viewId:String;	
		public var viewItemPositioner:ViewItemPositioner;
		public var viewRenderer:ViewRenderer;
		public var vmg:ViewModelGateway;
		public var vu:ViewUtils = ViewUtils.gi();
		public var numViewItems:int;

		public var viewItemTransition:ViewItemTransition;
		public var statusField:*;
		public var vp:ViewProperties;
		public	var vpm:NestedPropsManager;		
		public var filters:Array;

		public var itemDictionary:gDictionary;
		public var containergDictionary:gDictionary;

		public var disabledList:Array;
		public var itemWithFocus:*;
		public var itemWithFocusIndex:int;
		
		public function ViewController()
		{
			_init();
		}
		
		private function _init():void
		{
			viewRenderer = new ViewRenderer(this, processNextViewItem);
			vmg = new ViewModelGateway(this);
			viewItemPositioner = new ViewItemPositioner(this);
			_viewEvents = new ViewEvents(this);
			
			vpm = Props.views;
			_ap = ApplicationProperties.gi();
		}
	
		public function load(viewId:String, appState:String, onComplete:Function):void
		{			
			
			_onComplete = onComplete;
			vp = vpm.getPropsById(viewId);

			if (!vp)
				throw new Error("No view properties for viewId: " + viewId);
			
			vp.appState = appState;
			this.viewId = viewId;
			ViewControllerRegistry.registerController(viewId, this);
			ObjectPool.getContainer(vp);
			_container = vp.container;
			_container.viewController = this;
			viewRenderer.vp = vp;
			
			filters = [];
			disabledList = [];
			itemDictionary = new gDictionary();
			containergDictionary = new gDictionary();			
			_itemIndex = 0;
			initMessages();			
			
			Plugins.callMethod(vp.uiControllerInstanceName, PluginMethods.INIT, { controller:this, id:viewId } );
			_defaultVO = Plugins.callMethod(vp.uiControllerInstanceName, PluginMethods.GET_VALUE_OBJECT);
			numViewItems = vpm.getNumItems(viewId);
			processNextViewItem();
		}
		
		
		// PUBLIC METHODS
		
		public function get container():ViewContainer
		{
			return _container;
		}
		
		public function callAppControllerMethod(method:String, arg:*):void
		{
			Plugins.callMethod(vp.uiControllerInstanceName, method, arg);
		}
		
		public function setModelValue(itemName:String, val:*):void
		{
			if (_defaultVO)
			{	
				_defaultVO[itemName] = val;
				copyModelToView(itemName);
			}
		}
		
		public function getModelValue(itemName:String):*
		{
			if (_defaultVO)
				return _defaultVO[itemName];
		}
			
		public function setItemWithFocus(itemName:String):void
		{
			if (itemName)
			{
				itemWithFocus = getItemByName(itemName);
				itemWithFocusIndex = getItemIndexByName(itemName);
				Focus.show(itemWithFocus, container);
			}
			else	
			{
				itemWithFocus = getItemByIndex(0);
				itemWithFocusIndex = 0;
				_viewEvents.validateSelection(new HotKeyEvent(HotKeyEvent.HOTKEY_PRESS, "down"));
			}
			_viewEvents.onItemFocusIn();
		}
		
		public function onModelChange(itemNames:String=null):void
		{
			var items:Array
			
			if (itemNames)
			{
				items = itemNames.split(",");
				for (var i:int = 0; i < items.length; i++)
					copyModelToView(items[i]);
			}
			else
			{
				setStatusMessage(successMessage);
				copyModelToView();
			}
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
			{
				setStatusMessage(updatingMessage);
				copyViewToModel();
			}
		}
		
		private function copyViewToModel(itemName:String = null):void
		{
			var vip:ViewItemProperties;
			var item:*;
			
			if (itemName)
			{
				vip = vpm.getItemPropsByName(viewId, itemName);
			
				if (vip)
				{
					Plugins.callMethod(vp.uiControllerInstanceName, PluginMethods.VALUE_UPDATED, { itemName:vip.name, voName:vip.voName } );
					item = itemDictionary.getByKey(itemName);
					vmg.copyViewItemToValueObject(vip, item);
				}
				else
					throw new Error("ModelGateway: invalid item name " + itemName + " for view: " + viewId);
			}
			else
				for (var i:int = 0; i < numViewItems; i++) 
				{
					vip = vpm.getItemPropsByIndex(viewId, i);
						
					Plugins.callMethod(vp.uiControllerInstanceName, PluginMethods.VALUE_UPDATED, { itemName:vip.name, voName:vip.voName } );
					if (vip.voName)
					{
						item = itemDictionary.getByIndex(i);
						vmg.copyViewItemToValueObject(vip, item);
					}
				}
		}
		
		private function copyModelToView(itemName:String=null):void
		{
			var vip:ViewItemProperties;
			var item:*;

			if (itemName)
			{
				vip = vpm.getItemPropsByName(viewId, itemName);
				if (vip)
				{
					item = itemDictionary.getByKey(itemName);
					vmg.copyValueObjectToViewItem(vip, item);
				}
				else
					throw new Error("ModelGateway: invalid item name " + itemName + " for view: " + viewId);
			}
			else
				for (var i:int = 0; i < numViewItems; i++) 
				{
					vip = vpm.getItemPropsByIndex(viewId, i);
					if (vip.voName)
					{
						item = itemDictionary.getByIndex(i);
						vmg.copyValueObjectToViewItem(vip, item);
					}
				}
		}				
		
		public function onModelError(responds:Object=null):void
		{
			setStatusMessage(errorMessage);
		}		
		
		// PUBLIC STOP & CLEANUP (WHEN VIEW CONTAINER IS CLOSED) 
				
		public function stop():void
		{
			var item:*;
			
			for (var i:int = 0; i < numViewItems; i++)
			{
				item = itemDictionary.getByIndex(i);
				if (item is IMediaPlayer)
				{
					item.stop();
				}
			}
		}
		
		public function dispose():void
		{
			var i:int;
			var numFilters:int;
			var l:int;
			var c:ViewContainer;
		
			ViewControllerRegistry.unregisterController(viewId);
			
			_viewEvents.itemListenerCleanup();
			
			l = containergDictionary.length;
			for (i = 0; i < l; i++) 
			{
				c = containergDictionary.getByIndex(i);
				_viewEvents.removeListenersFromContainer(c);
			}
			
			if (filters)
			{
				numFilters = filters.length;
				for (i = 0; i < numFilters; i++)
					filters[i].dispose();
			}
				
			filters = null;
			if (itemDictionary)
			{
				itemDictionary.dispose();
				itemDictionary = null;
			}
			numViewItems = 0;
			viewRenderer = null;
			vmg = null;
			_viewEvents = null;		
			Plugins.callMethod(vp.uiControllerInstanceName, PluginMethods.DISPOSE)			
		}
		
		// GET THE UI ITEM's OBJECT OR PROPERTIES
		
		public function getItemByIndex(indx:int):*
		{
			return itemDictionary.getByIndex(indx);
		}
		
		public function getItemIndexByName(name:String):int
		{
			return itemDictionary.getIndexByKey(name);
		}
		
		public function getItemByName(itemName:String):*
		{
			var vip:ViewItemProperties;
			var item:*
			
			vip = vpm.getItemPropsByName(viewId, itemName);
			if (vip)
				if (itemDictionary)
					item = itemDictionary.getByKey(itemName);

			return item;
		}
		
		public function getItemPropsByName(itemName:String):ViewItemProperties
		{
			return vpm.getItemPropsByName(viewId, itemName);
		}
		
		public function getItemPropsByIndex(index:int):ViewItemProperties
		{
			return vpm.getItemPropsByIndex(viewId, index);
		}
		
		
		// VIEW DISPLAY RELATED METHODS
		
		public function setItemAlpha(itemName:String, a:Number):void		
		{
			var vip:ViewItemProperties;
			var item:*
			
			vip = vpm.getItemPropsByName(viewId, itemName);
			if (vip)
				if (itemDictionary)
				{
					item = itemDictionary.getByKey(itemName);
					if (item)
						item.alpha = a;
				}
		}
		
		public function setAllItemVisibility(visible:Boolean=true, fade:Number = 0, delay:Number = 0):void
		{
			var ni:int;
			
			setItemVisibility(null, visible, fade, delay);
			if (itemDictionary)
			{
				ni = itemDictionary.length;
				for (var i:int = 0; i < ni; i++)
					ItemFX.fade(vp.name, itemDictionary.getByIndex(i), visible, fade, delay);
			}
		}
		
		public function setItemVisibility(name:String, visible:Boolean = true, fade:int = 0, delay:int = 0):void
		{
			ItemFX.fade(vp.name, itemDictionary.getByKey(name), visible, fade, delay);
		}
		
		public function get numItems():int
		{
			return itemDictionary.length;
		}
		
		public function setDisabled(itemName:String, d:Boolean):void
		{
			var item:*;
			
			item = itemDictionary.getByKey(itemName);
			if (item)
			{
				disabledList[ itemDictionary.getIndexByKey(itemName) ] = d;
				if(item.hasOwnProperty("enabled"))
					item.enabled = d;
			}
		}
		
		public function getDisabled(itemName:String):Boolean
		{
			var item:*
			
			item = getItemByName(itemName); 
			if (item.alpha == 0 || item.visible == false)
				return true;
			
			return disabledList[ itemDictionary.getIndexByKey(itemName) ];
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
				
		public function setStatusMessage(s:String):void
		{
			var vip:ViewItemProperties;
			
			if (statusField)
			{
				if (s)
					statusField.text = s;
				else
					statusField.text = "";

				vip = vpm.getItemPropsByName(viewId, "status");
				TextUtil.applyTextAttributes(statusField, vip.textAttributes, int(vip.width), int(vip.height));
			}		
		}
						
		public function initStatusMessage(m:String):void
		{
			switch (m)
			{
				case UIEvent.READ :
				case UIEvent.NEXT :
				case UIEvent.PREVIOUS :
				case UIEvent.LAST :
				case UIEvent.FIRST :
					setStatusMessage(readingMessage);
					break;
				case UIEvent.PURGE :
					setStatusMessage(deletingMessage);
					break;
				case UIEvent.UPDATE :
					setStatusMessage(updatingMessage);
					break;
			}	
		}
		
		//EVENT DISPATCH
		
		public function dispatchMenuSelection(ms:String):void
		{
			vp.container.dispatchEvent(new UIEvent(UIEvent.MENU_SELECTION, vp.container.name, ms));
		}
		
		public function dispatchUiEvent(eventType:String):void
		{
			vp.container.dispatchEvent(new UIEvent(eventType, vp.container.name));
		}				
		
		// PRIVATE METHODS

		private function processNextViewItem(e:Event = null):void
		{	
			if (_itemIndex < numViewItems)
				viewRenderer.renderItem(_itemIndex++);
			else
				viewPopulateComplete();
		}
		
		private function initMessages():void
		{
			var messages:Array = [ READING, CREATING, DELETING, UPDATING, SUCCESS, ERROR ];
			var vip:ViewItemProperties;
			var s:String;

			for (s in messages)
			{
				vip = vpm.getItemPropsByName(viewId, messages[s]);
				if (vip)
					if (vip.tText)
						this[messages[s]] = Translate(vip.tText);
					else	
						this[messages[s]] = "";
			}
		}
		
		// FINISH UP VIEW RENDER
		
		private function viewPopulateComplete():void
		{
			var i:int;
			var l:int;
			var c:int;
			var disabledCount:int;
			var vip:ViewItemProperties;			
			
			l = containergDictionary.length;
			c = itemDictionary.length;
			_viewEvents.itemListenerSetup();				
			
			_onComplete();
			
			for (i = 0; i < l; i++)
			{
				_viewEvents.addListenersToContainer(containergDictionary.getByIndex(i));
			}
			for (i = 0; i < c; i++)
			{
				vip = vpm.getItemPropsByIndex(viewId, i);
				if (vip && vip.transitionPreset) {
					viewItemTransition = new ViewItemTransition();
					viewItemTransition.render(vip, itemDictionary, TransitionTypes.IN);
				}
			}
			
			if (vp.initialMethod)
			{
				initStatusMessage(vp.initialMethod);
				if (vp.initialMethodParams)
					Plugins.callMethod(vp.uiControllerInstanceName, vp.initialMethod,vp.initialMethodParams);
				else
					Plugins.callMethod(vp.uiControllerInstanceName, vp.initialMethod);
			}
			vmg.setAllInitialValues();
		}
	}
}
