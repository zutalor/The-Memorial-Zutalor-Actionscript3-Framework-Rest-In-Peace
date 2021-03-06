package com.zutalor.view.mediators
{
	import com.zutalor.air.AirStatus;
	import com.zutalor.analytics.Analytics;
	import com.zutalor.components.base.Component;
	import com.zutalor.components.button.Button;
	import com.zutalor.components.group.ComponentGroup;
	import com.zutalor.components.group.ComponentGroupProperties;
	import com.zutalor.components.group.RadioGroup;
	import com.zutalor.components.text.Text;
	import com.zutalor.containers.Container;
	import com.zutalor.events.HotKeyEvent;
	import com.zutalor.events.UIEvent;
	import com.zutalor.loaders.URL;
	import com.zutalor.plugin.constants.PluginClasses;
	import com.zutalor.plugin.constants.PluginMethods;
	import com.zutalor.plugin.Plugins;
	import com.zutalor.properties.NestedPropsManager;
	import com.zutalor.translate.Translate;
	import com.zutalor.utils.FullScreen;
	import com.zutalor.utils.HotKeyManager;
	import com.zutalor.view.controller.ViewController;
	import com.zutalor.view.properties.ViewItemProperties;
	import com.zutalor.view.properties.ViewProperties;
	import com.zutalor.widgets.Focus;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ViewEventMediator
	{
		public var vc:ViewController;
		
		private var _vpm:NestedPropsManager;
		private var _hkm:HotKeyManager;
		private var _itemsSkipped:int;
		private var _numItems:int;
		
		public static var navKeys:Array = ["RIGHT", "right", "LEFT", "left", "TAB", "tab", "DOWN", "down", "SHIFT+TAB", "shift+tab", "UP", "up", "SPACE", "space"];
		
		public function ViewEventMediator(viewController:ViewController)
		{
			vc = viewController;
			_init();
		}
		
		private function _init():void
		{
			_vpm = ViewController.presets;
			_hkm = HotKeyManager.gi();
		}
		
		public function addListenersToContainer(c:Container):void
		{
			var vip:ViewItemProperties;
			var keys:Array;
			var i:int;
			var numKeys:int;
			_numItems = vc.numViewItems;
			listenerUtil(c.addEventListener);
			_hkm.addEventListener(HotKeyEvent.HOTKEY_PRESS, onHotKey, false, 0, true);
			
			numKeys = navKeys.length - 1;
			for (i = 0; i < numKeys; i += 2)
			{
				_hkm.addMapping(navKeys[i], navKeys[i + 1]);
			}
			for (i = 0; i < _numItems; i++)
			{
				vip = vc.getItemPropsByIndex(i);
				if (vip.hotkey)
				{
					keys = vip.hotkey.split(",");
					for (var k:int = 0; k < keys.length; k++)
						_hkm.addMapping(keys[k], vip.name);
				}
			}
		}
		
		public function removeListenersFromContainer(c:Container):void
		{
			var vip:ViewItemProperties;
			var numKeys:int;
			var keys:Array;
		
			listenerUtil(c.removeEventListener);
			_hkm.removeEventListener(HotKeyEvent.HOTKEY_PRESS, onHotKey);
			
			numKeys = navKeys.length - 1;
			for (i = 0; i < numKeys; i += 2)
				_hkm.removeMapping(navKeys[i]);
			
			for (var i:int = 0; i < vc.numViewItems; i++)
			{
				vip = vc.getItemPropsByIndex(i);
				if (vip.hotkey)
				{
					keys = vip.hotkey.split(",");
					for (var k:int = 0; k < keys.length; k++)
						_hkm.removeMapping(keys[k]);
				}
			}
		}
		
		private function listenerUtil(f:Function):void
		{
			f(MouseEvent.CLICK, onTap);
			f(UIEvent.VALUE_CHANGED, onValueChange);
		}
		
		public function itemListenerSetup():void
		{
			var item:Component;
			
			for (var i:int = 0; i < _numItems; i++)
			{
				item = vc.container.getChildAt(i) as Component;
					
				if (item is Text && item.editable)
				{
					item.addEventListener(FocusEvent.FOCUS_IN, onInputTextFocusIn);
					item.addEventListener(FocusEvent.FOCUS_OUT, onInputTextFocusOut);
					item.addEventListener(Event.CHANGE, removeLeadingSpaces);
				}
				else
					item.addEventListener(FocusEvent.FOCUS_IN, onItemFocusIn);
			}
		}
		
		public function validateSelection(e:HotKeyEvent):void
		{
			var item:Component;
			
			item = vc.getItemByIndex(vc.itemWithFocusIndex);
			if ( item.editable && item.enabled)
			{
				vc.itemWithFocus = item;
				if (vc.itemWithFocus.visible && vc.itemWithFocus.alpha > 0)
					onItemFocusIn();
				else
				{
					if (_itemsSkipped < _numItems)
					{
						_itemsSkipped++;
						onHotKey(e);
					}
					else
						_itemsSkipped--;
				}
			}
			else if (_itemsSkipped < _numItems)
			{
				_itemsSkipped++;
				onHotKey(e);
			}
			else
				_itemsSkipped--;
		}
		
		private function removeLeadingSpaces(e:Event):void
		{
			while (e.target.text.charAt(0) == " ")
			{
				e.target.text = e.target.text.substring(1, e.target.text.length);
			}
		}
		
		public function itemListenerCleanup():void
		{
			var l:int;
			var item:*;
			
			if (vc.container.numChildren)
			{
				l = vc.container.numChildren;
				for (var i:int = 0; i < l; i++)
				{
					item = vc.container.getChildAt(i);
					if (item is TextField && item.hasEventListener(FocusEvent.FOCUS_IN))
					{
						item.removeEventListener(FocusEvent.FOCUS_IN, onInputTextFocusIn);
						item.removeEventListener(FocusEvent.FOCUS_OUT, onInputTextFocusOut);
						item.removeEventListener(Event.CHANGE, removeLeadingSpaces);
					}
					else if (item.hasEventListener(FocusEvent.FOCUS_IN))
						item.removeEventListener(FocusEvent.FOCUS_IN, onItemFocusIn);
					
					item.removeEventListener(UIEvent.VALUE_CHANGED, onValueChange);
				}
			}
		}
		
		public function onItemFocusIn(fe:FocusEvent = null):void
		{
			var vip:ViewItemProperties;
			var item:Component;
			
			if (fe)
				item = vc.itemWithFocus = Component(fe.currentTarget);
			else
				item = vc.itemWithFocus;
			
			if (item)
			{
				if (!item.enabled && item.visible && item.alpha > 0)
				{
					Focus.show(item, vc.container);
					vip = vc.getItemPropsByName(item.name);
					if (vc.vp.uxControllerInstanceName)
						Plugins.callMethod(vc.vp.uxControllerInstanceName, PluginMethods.ON_FOCUS_IN, {itemWithFocus: item, focusEvent: fe});
				}
			}
		}
		
		private function onInputTextFocusIn(fe:FocusEvent):void
		{
			var vip:ViewItemProperties;
			var item:Component;
			vip = _vpm.getItemPropsByName(vc.viewId, fe.currentTarget.name);
		
			FullScreen.restoreIfNotDesktop();
			item = vc.container.getChildByName(vip.name) as Component;
			vip.text = Translate.text(vip.tKey);
				
			if (item.value == vip.text)
				item.value = "";

			onItemFocusIn(fe);
		}
		
		private function onInputTextFocusOut(fe:FocusEvent):void
		{
			var vip:ViewItemProperties;
			var item:Component
			
			item = fe.currentTarget as Component;
			
			vip = _vpm.getItemPropsByName(vc.viewId, item.name);
		
			if (item.value == "" && vip.tKey)
				item.value = Translate.text(vip.tKey);
		
			if (vip.voName)
				vc.viewModelMediator.copyViewItemToValueObject(vip, item);
		}
		
		private function onHotKey(e:HotKeyEvent):void
		{
			var t:String;
			var r:RadioGroup;
			var cn:Button;
			var vip:ViewItemProperties;
			var tmp:*;
			
			r = vc.itemWithFocus as RadioGroup;
			
			if (vc.container.visible)
			{
				switch (e.message)
				{
					case "left":
						if (getQualifiedClassName(vc.itemWithFocus).indexOf("RadioGroup") > -1)
						{
							if (r.radioIndex > 0)
								r.radioIndex--;
							else
								r.radioIndex = r.numButtons - 1;
						}
						break;
					case "right":
						if (getQualifiedClassName(vc.itemWithFocus).indexOf("RadioGroup") > -1)
						{
							if (r.radioIndex < r.numButtons - 1)
								r.radioIndex++;
							else
								r.radioIndex = 0;
						}
						break;
						
						break;
					case "down":
						if (vc.itemWithFocusIndex < _numItems - 1)
							vc.itemWithFocusIndex++;
						else
							vc.itemWithFocusIndex = 0;
						
						validateSelection(e);
						break;
					case "up":
						if (vc.itemWithFocusIndex > 0)
							vc.itemWithFocusIndex--;
						else
							vc.itemWithFocusIndex = _numItems - 1;
						
						validateSelection(e);
						break;
					
					case "space":
						if (getQualifiedClassName(vc.itemWithFocus).indexOf("Button") > -1)
							onTap(null, vc.itemWithFocus.name);
						else if (getQualifiedClassName(vc.itemWithFocus).indexOf("Toggle") > -1)
						{
							vc.itemWithFocus.value = !vc.itemWithFocus.value;
							vip = _vpm.getItemPropsByName(vc.viewId, vc.itemWithFocus.name);
							vc.viewModelMediator.copyViewItemToValueObject(vip, vc.container.getChildByName(vip.name));
						}
						break;
					default:
						tmp = vc.getItemByName(e.message);
						if (tmp)
							if (tmp.visible && tmp.alpha > 0)
							{
								vc.itemWithFocus = tmp;
								vc.itemWithFocusIndex = vc.getItemIndexByName(e.message);
								onTap(null, e.message);
							}
				}
			}
		}
		
		private function onValueChange(uie:UIEvent):void
		{
			var vip:ViewItemProperties;
			var cgp:ComponentGroupProperties;
			var cg:ComponentGroup;
			var contentContainer:*;
			
			if (uie.itemName)
				vip = _vpm.getItemPropsByName(vc.viewId, uie.itemName);
			else
				vip = _vpm.getItemPropsByName(vc.viewId, uie.target.name);
			
			if (vip && vip.voName)
			{
				vc.onViewChange(vip.name);
				if (uie.target is ComponentGroup || uie.target is RadioGroup)
				{
					cgp = ComponentGroup.presets.getPropsByName(vip.presetId);
					cg = vc.container.getChildByName(uie.itemName) as ComponentGroup;
					contentContainer = cg.getChildAt(0);
					for (var i:int = 0; i < cgp.numComponents; i++)
						contentContainer.getChildAt(i).value = uie.value[i];
				}
			}
		}
		
		private function callViewItemMethod(viewName:String, viewItemName:String, method:String, params:String):void
		{
			var vp:ViewProperties;
			
			vp = ViewController.presets.getPropsById(viewName);
			vp.container.callContainerChildMethod(viewItemName, method, params);
		}
		
		private function callViewContainerMethod(viewName:String, method:String, params:String):void
		{
			var vp:ViewProperties;
			
			vp = ViewController.presets.getPropsById(viewName); //TODO Error check
			vp.container.callContainerMethod(method, params);
		}
		
		private function zoom(uie:UIEvent=null, type:String=null, viewName:String = null):void
		{
			var vp:ViewProperties;
			var c:*;
			var vName:String;
			var zType:String;
			var oldScrollX:Number;
			var oldScrollY:Number;
			
			if (viewName)
				vName = viewName;
			else
				vName = uie.target.name;
				
			if (type)
				zType = type;
			else
				zType = uie.type;
				
			vp = ViewController.presets.getPropsById(vName);
			c = vp.container;
			
			if (zType == UIEvent.ZOOM_IN)
			{
				c.width += c.width * .1;
				c.height += c.height * .1;
			}
			else
			{
				c.width -= c.width * .1;
				c.height -= c.height * .1;
			}
			vp.container.contentChanged();
		}
		
		private function onTap(me:MouseEvent = null, targetName:String = null):void
		{
			var vip:ViewItemProperties;
			var eventTargetName:String;
			var i:int;
			var containerNames:Array;
			var events:Array;
			var eventIndx:int;
			var target:String;
			
			if (targetName != null)
				eventTargetName = targetName;
			else
			{
				if (me.target.alpha == 0 || me.target.visible == false)
					return;
				else
					eventTargetName = me.target.name;
			}
			
			if (eventTargetName)
			{
				vip = _vpm.getItemPropsByName(vc.viewId, eventTargetName);
				if (vip && vip.tapAction)
				{
					if (me)
						me.stopImmediatePropagation();
					
					if (!vip.tapContainerNames)
					{
						containerNames = [];
						containerNames.push(vc.container.name);
					}
					else
						containerNames = vip.tapContainerNames.split(",");

					switch (vip.onTap)
					{
						case ViewItemProperties.UI_EVENT :
							uiEvent();
							break;
						case ViewItemProperties.APP_STATE_CHANGE :
							appStateChange();
							break;
						case ViewItemProperties.PLUGIN_METHOD :
							PluginMethodCall();
							break;
						case ViewItemProperties.CONTAINER_METHOD :
							containerMethodCall();
							break;
						case ViewItemProperties.VIEWITEM_METHOD :
							viewItemMethodCall();
							break;
						case ViewItemProperties.URL :
								Analytics.trackPageView(vip.tapAction);
							url();
							break;
						default :
							break;
					}
					
					function url():void
					{
						URL.open(vip.tapAction);
					}
					
					function appStateChange():void
					{
						vc.container.dispatchEvent(new UIEvent(UIEvent.APP_STATE_SELECTED,
																vc.container.name, vip.tapAction));
					}
					
					function viewItemMethodCall():void
					{
						for (i = 0; i < containerNames.length; i++)
							callViewItemMethod(containerNames[i], vip.tapTarget, vip.tapAction, vip.tapActionOptions);
					}
					
					function PluginMethodCall():void
					{
						var dest:String;
						
						dest = vc.vp.uxControllerInstanceName;
						
						if (vip.voName)
							vc.viewModelMediator.copyViewItemToValueObject(vip, vc.container.getChildByName(vip.name));
						
						if (vip.tapActionOptions)
							Plugins.callMethod(dest, vip.tapAction, vip.tapActionOptions);
						else
							Plugins.callMethod(dest, vip.tapAction);
					}
					
					function containerMethodCall():void
					{
						for (i = 0; i < containerNames.length; i++)
							callViewContainerMethod(containerNames[i], vip.tapAction, vip.tapActionOptions);
					}
						
					function uiEvent():void
					{
						var dest:String;
						dest = vc.vp.uxControllerInstanceName;
						
						switch (vip.tapAction)
						{
							case UIEvent.CREATE:
							case UIEvent.UPDATE:
								if (vc.viewModelMediator.validate())
									if (vip.tapActionOptions)
										Plugins.callMethod(dest, vip.tapAction, vip.tapActionOptions);
									else
										Plugins.callMethod(dest, vip.tapAction);
								break;
							case UIEvent.ZOOM_IN:
							case UIEvent.ZOOM_OUT:
								for (i = 0; i < containerNames.length; i++)
									zoom(null, vip.tapAction, containerNames[i]);
								break;
							case UIEvent.NATIVE_WINDOW_CLOSE:
								if (AirStatus.isNativeApplication)
									Plugins.callMethod(PluginClasses.AIR_PLUGIN, PluginMethods.NW_CLOSE);
								break;
							case UIEvent.NATIVE_APPLICATION_EXIT:
								if (AirStatus.isNativeApplication)
									Plugins.callMethod(PluginClasses.AIR_PLUGIN, PluginMethods.NATIVE_APP_EXIT);
								break;
							case UIEvent.NATIVE_WINDOW_MAXIMIZE:
								if (AirStatus.isNativeApplication)
									Plugins.callMethod(PluginClasses.AIR_PLUGIN, PluginMethods.NW_MAXIMIZE);
								break;
							case UIEvent.NATIVE_WINDOW_MINIMIZE:
								if (AirStatus.isNativeApplication)
									Plugins.callMethod(PluginClasses.AIR_PLUGIN, PluginMethods.NW_MINIMIZE);
								break;
							case UIEvent.FULLSCREEN:
								FullScreen.toggle();
								break;
							default:
								var c:Container = ViewController.presets.getPropsById(containerNames[i]).container;
								for (i = 0; i < containerNames.length; i++)
									c.dispatchEvent(new UIEvent(vip.tapAction, containerNames[i], vc.vp.appState));
						}
					}
				}
			}
		}
	}
}