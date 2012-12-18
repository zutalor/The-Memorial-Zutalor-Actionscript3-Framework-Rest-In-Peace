package com.zutalor.view.controller
{
	import com.greensock.TweenMax;
	import com.gskinner.utils.IDisposable;
	import com.zutalor.components.base.Component;
	import com.zutalor.containers.ViewContainer;
	import com.zutalor.events.HotKeyEvent;
	import com.zutalor.events.UIEvent;
	import com.zutalor.fx.Transition;
	import com.zutalor.fx.TransitionTypes;
	import com.zutalor.interfaces.IMediaPlayer;
	import com.zutalor.plugin.constants.PluginMethods;
	import com.zutalor.plugin.Plugins;
	import com.zutalor.propertyManagers.NestedPropsManager;
	import com.zutalor.utils.ShowError;
	import com.zutalor.utils.StageRef;
	import com.zutalor.view.mediators.ViewEventMediator;
	import com.zutalor.view.mediators.ViewModelMediator;
	import com.zutalor.view.properties.ViewItemProperties;
	import com.zutalor.view.properties.ViewProperties;
	import com.zutalor.view.rendering.ViewItemFilterApplier;
	import com.zutalor.view.rendering.ViewItemPositioner;
	import com.zutalor.view.rendering.ViewRenderer;
	import com.zutalor.view.transition.ItemFX;
	import com.zutalor.view.transition.ViewItemTransition;
	import com.zutalor.widgets.Focus;
	import flash.display.Bitmap;
	import flash.display.BitmapData;

	public class ViewController implements IDisposable
	{		
		private var _onComplete:Function;
		private var _itemIndex:int;
		private var _viewEventMediator:ViewEventMediator;
		private var _defaultVO:*;
		private var _viewId:String;	
		private var _viewItemFilterApplier:ViewItemFilterApplier;
		private var _viewItemPositioner:ViewItemPositioner;
		private var _viewRenderer:ViewRenderer;
		private var _numViewItems:int;
		private var _filters:Array;
		private var _viewItemTransition:ViewItemTransition;
		
		public var vp:ViewProperties;	
		public var itemWithFocus:Component;
		public var itemWithFocusIndex:int;		
		public var onStatus:Function;		
		public var viewModelMediator:ViewModelMediator;
		
		private static var _presets:NestedPropsManager;
				
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
	
		public function load(vc:ViewContainer, viewId:String, appState:String, onComplete:Function):void
		{	
			_viewId = viewId;
			_onComplete = onComplete;
			vp = _presets.getPropsById(_viewId);
			_filters = [];
			_itemIndex = 0;			

			if (!vp)
				ShowError.fail(ViewController,"No view properties for viewId: " + _viewId);
			
			vp.appState = appState;
			ViewControllerRegistry.registerController(_viewId, this);
			vp.container = vc;
			vp.container.viewController = this;

			if (vp.uiControllerInstanceName)
			{
				Plugins.callMethod(vp.uiControllerInstanceName, PluginMethods.INIT, { controller:this, id:_viewId } );
				_defaultVO = Plugins.callMethod(vp.uiControllerInstanceName, PluginMethods.GET_VALUE_OBJECT);
				viewModelMediator = new ViewModelMediator(this);
			}
			_viewItemPositioner = new ViewItemPositioner(vp.container, vp.width, vp.height);
			_viewEventMediator = new ViewEventMediator(this);
			_viewItemFilterApplier = new ViewItemFilterApplier(_filters);
			_viewRenderer = new ViewRenderer(vp.container, renderNextViewItem, _viewItemFilterApplier.applyFilters, 
																				_viewItemPositioner.positionItem);			
			_numViewItems = _presets.getNumItems(_viewId);	
			renderNextViewItem();
		}
		
		
		// PUBLIC METHODS
		
		public function get numViewItems():int
		{
			return _numViewItems;
		}
		
		public function get viewId():String
		{
			return _viewId;
		}
		
		public function get container():ViewContainer
		{
			return vp.container;
		}
					
		public function positionAllItems():void
		{
			for (var i:int; i < _numViewItems; i++)
				_viewItemPositioner.positionItem(_presets.getItemPropsByIndex(_viewId, i));
		}
		
		public function callUiControllerMethod(method:String, arg:*, controllerId:String = null):void
		{
			if (!controllerId)
				controllerId = vp.uiControllerInstanceName;
			
			Plugins.callMethod(controllerId, method, arg);
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
				Focus.show(itemWithFocus, vp.container);
			}
			else	
			{
				itemWithFocus = getItemByIndex(0);
				itemWithFocusIndex = 0;
				_viewEventMediator.validateSelection(new HotKeyEvent(HotKeyEvent.HOTKEY_PRESS, "down"));
			}
			_viewEventMediator.onItemFocusIn();
		}
		
		public function onModelChange(itemNames:String = null, transition:String = null, onTransitionComplete:Function = null):void
		{
			var items:Array
			var t:Transition;
			var bmd:BitmapData;
			var bm:Bitmap;
			
			if (transition)
			{
				bmd = new BitmapData(StageRef.stage.stageWidth, StageRef.stage.stageHeight);
				bmd.draw(vp.container);
				bm = new Bitmap(bmd);
				bm.visible = true;
				StageRef.stage.addChild(bm);				
				t = new Transition();
				t.simpleRender(bm, transition, "out", hideBm);
				
				function hideBm():void
				{
					bm.visible = false;
				}
			}
			if (itemNames)
			{
				items = itemNames.split(",");
				for (var i:int = 0; i < items.length; i++)
					copyModelToView(items[i]);
			}
			else
				copyModelToView();

			if (transition)
			{
				t = new Transition();
				t.simpleRender(vp.container, transition, "in", onTransitionComplete);
			}
			else
				if (onTransitionComplete != null)
					onTransitionComplete();
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
				vip = _presets.getItemPropsByName(_viewId, itemName);
			
				if (vip.voName)
				{
					Plugins.callMethod(vp.uiControllerInstanceName, PluginMethods.VALUE_UPDATED, { itemName:vip.name, voName:vip.voName } );
					item = vp.container.getChildByName(itemName) as Component;
					viewModelMediator.copyViewItemToValueObject(vip, item);
				}
				else
					ShowError.fail(ViewController,"invalid item name " + itemName + " for view: " + _viewId);
			}
			else
				for (var i:int = 0; i < _numViewItems; i++) 
				{
					vip = _presets.getItemPropsByIndex(_viewId, i);
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
				vip = _presets.getItemPropsByName(_viewId, itemName);
				if (vip.voName)
				{
					item = vp.container.getChildByName(itemName) as Component;
					viewModelMediator.copyValueObjectToViewItem(vip, item);
				}
				else
					ShowError.fail(ViewController, "Invalid item name " + itemName + " for view: " + _viewId);
			}
			else
				for (var i:int = 0; i < _numViewItems; i++) 
				{
					vip = _presets.getItemPropsByIndex(_viewId, i);
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
			
			for (var i:int = 0; i < _numViewItems; i++)
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
		
			ViewControllerRegistry.unregisterController(_viewId);
			
			_viewEventMediator.itemListenerCleanup();
			_viewEventMediator.removeListenersFromContainer(container);
			
			if (_filters)
			{
				numFilters = _filters.length;
				for (i = 0; i < numFilters; i++)
					_filters[i].dispose();
			}
			vp.container.dispose();	
			_filters = null;
			_numViewItems = 0;
			_viewRenderer = null;
			viewModelMediator = null;
			_viewEventMediator = null;		
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
			
			vip = _presets.getItemPropsByName(_viewId, itemName);
			if (vip && vp.container.numChildren)
				item = vp.container.getChildByName(itemName) as Component;

			return item;
		}
		
		public function getItemPropsByName(itemName:String):ViewItemProperties
		{
			return _presets.getItemPropsByName(_viewId, itemName);
		}
		
		public function getItemPropsByIndex(index:int):ViewItemProperties
		{
			return _presets.getItemPropsByIndex(_viewId, index);
		}
		
		
		// VIEW DISPLAY RELATED METHODS
		
		public function setItemAlpha(itemName:String, a:Number):void		
		{
			var vip:ViewItemProperties;
			var item:Component;
			
			vip = _presets.getItemPropsByName(_viewId, itemName);
			if (vip && vp.container.numChildren)
				item = vp.container.getChildByName(itemName) as Component;
				if (item)
					item.alpha = a;
		}
		
		public function setAllItemVisibility(visible:Boolean=true, fade:Number = 0, delay:Number = 0):void
		{
			var ni:int;
			
			setItemVisibility(null, visible, fade, delay);
			if (vp.container.numChildren)
			{
				ni = vp.container.numChildren;
				for (var i:int = 0; i < ni; i++)
					ItemFX.fade(vp.name, vp.container.getChildAt(i), visible, fade, delay);
			}
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
		
		// PRIVATE METHODS

		private function renderNextViewItem():void
		{	
			var vip:ViewItemProperties;
			
			if (_itemIndex < _numViewItems)
			{
				vip = _presets.getItemPropsByIndex(_viewId, _itemIndex++);
				if (!vip.styleSheetName)
					vip.styleSheetName = vp.styleSheetName;
				_viewRenderer.renderItem(vip);
			}	
			else
				viewPopulateComplete();
		}
		
		// FINISH UP VIEW RENDER
		
		private function viewPopulateComplete():void
		{
			var i:int;
			var l:int;
			var c:int;

			var vip:ViewItemProperties;			
			c = container.numChildren;
			_viewEventMediator.itemListenerSetup();				
			_viewEventMediator.addListenersToContainer(vp.container);
			vp.container.arranger.resize(vp.resizeMode);
			vp.container.arranger.alignToStage(vp.align, vp.hPad, vp.vPad);
			_onComplete();
			
			for (i = 0; i < c; i++)
			{
				vip = _presets.getItemPropsByIndex(_viewId, i);
				if (vip && vip.transitionPreset) {
					_viewItemTransition = new ViewItemTransition();
					_viewItemTransition.render(vip, container, TransitionTypes.IN);
				}
			}
			
			if (vp.initialMethod)
			{
				if (vp.initialMethodParams)
					Plugins.callMethod(vp.uiControllerInstanceName, vp.initialMethod,vp.initialMethodParams);
				else
					Plugins.callMethod(vp.uiControllerInstanceName, vp.initialMethod);
			}
			if (viewModelMediator != null)
				viewModelMediator.setAllInitialValues();
		}
	}
}
