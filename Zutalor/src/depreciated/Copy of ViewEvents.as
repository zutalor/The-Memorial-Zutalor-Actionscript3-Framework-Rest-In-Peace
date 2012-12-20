package depreciated
{
	import com.zutalor.air.AirStatus;
	import com.zutalor.containers.ViewContainer;
	import com.zutalor.events.HotKeyEvent;
	import com.zutalor.events.UIEvent;
	import com.zutalor.audio.SoundPlayer;
	import com.zutalor.motion.MotionUtils;
	import com.zutalor.plugin.constants.PluginClasses;
	import com.zutalor.plugin.constants.PluginMethods;
	import com.zutalor.plugin.Plugins;
	import com.zutalor.properties.ComponentGroupProperties;
	import com.zutalor.properties.SoundFxProperties;
	import com.zutalor.view.properties.ViewItemProperties;
	import com.zutalor.propertyManagers.NestedPropsManager;
	import com.zutalor.propertyManagers.Presets;
	import com.zutalor.propertyManagers.Props;
	import com.zutalor.text.TextUtil;
	import com.zutalor.translate.Translate;
	import com.zutalor.ui.Button;
	import com.zutalor.ui.ComponentGroup;
	import com.zutalor.ui.Focus;
	import com.zutalor.ui.RadioGroup;
	import com.zutalor.ui.ToolTip;
	import com.zutalor.utils.FullScreen;
	import com.zutalor.utils.HotKeyManager;
	import com.zutalor.utils.StageRef;
	import com.zutalor.view.controller.ViewController;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ViewEvents
	{
		public var vc:ViewController;
		
		private var _vpm:NestedPropsManager;
		private var _vu:ViewUtils;
		private var _pr:Presets;
		private var _mu:MotionUtils;
		private var _hkm:HotKeyManager;
		private var _itemsSkipped:int;
		
		public static var navKeys:Array = ["RIGHT", "right", "LEFT", "left", "TAB", "down", "DOWN", "down", "SHIFT+TAB", "up", "UP", "up", "SPACE", "space"];
		
		public function ViewEvents(viewController:ViewController)
		{
			vc = viewController;
			_init();
		}
		
		private function _init():void
		{
			_vpm = Props.views;
			_vu = ViewUtils.gi();			
			_pr = Presets.gi();
			_mu = MotionUtils.gi();
			_hkm = new HotKeyManager();
		}
		
		public function addListenersToContainer(c:ViewContainer):void
		{
			var vip:ViewItemProperties;
			var keys:Array;
			var i:int;
			var numKeys:int;
			
			listenerUtil(c.addEventListener);
			_hkm.addEventListener(HotKeyEvent.HOTKEY_PRESS, onHotKey, false, 0, true);
			
			numKeys = navKeys.length - 1;
			for (i = 0; i < numKeys; i += 2)
				_hkm.addMapping(c, navKeys[i], navKeys[i + 1]);
			
			for (i = 0; i < vc.numViewItems; i++)
			{
				vip = vc.getItemPropsByIndex(i);
				if (vip.hotkey)
				{
					keys = vip.hotkey.split(",");
					for (var k:int = 0; k < keys.length; k++)
						_hkm.addMapping(vc.container, keys[k], vip.name);
				}
			}
		}
		
		public function removeListenersFromContainer(c:ViewContainer):void
		{
			var vip:ViewItemProperties;
			var numKeys:int;
			var keys:Array;
			
			listenerUtil(c.removeEventListener);
			_hkm.removeEventListener(HotKeyEvent.HOTKEY_PRESS, onHotKey);
			
			numKeys = navKeys.length - 1;
			for (i = 0; i < numKeys; i += 2)
				_hkm.removeMapping(vc.container, navKeys[i]);
			
			for (var i:int = 0; i < vc.numViewItems; i++)
			{
				vip = vc.getItemPropsByIndex(i);
				if (vip.hotkey)
				{
					keys = vip.hotkey.split(",");
					for (var k:int = 0; k < keys.length; k++)
						_hkm.removeMapping(vc.container, keys[k]);
				}
			}
		}
		
		private function listenerUtil(f:Function):void
		{
			f(MouseEvent.CLICK, onTap);
			f(MouseEvent.MOUSE_OVER, onMouseOver);
			f(MouseEvent.MOUSE_OVER, buttonSfx);
			f(MouseEvent.MOUSE_OUT, buttonSfx);
			f(MouseEvent.MOUSE_DOWN, buttonSfx);
			f(MouseEvent.MOUSE_DOWN, onMouseDown);
			f(UIEvent.VALUE_CHANGED, onValueChange);
		}
		
		public function itemListenerSetup():void
		{
			var vip:ViewItemProperties;
			var item:*;
			
			for (var i:int = 0; i < vc.numViewItems; i++)
			{
				vip = _vpm.getItemPropsByIndex(vc.viewId, i);
				item = vc.itemDictionary.getByIndex(i);
				
				if (item)
				{
					if (vip.onTap || vip.onTapDownUiEvent)
						if (!(item is TextField))
							item.buttonMode = true;
					
					if (vip.type == ViewItemProperties.INPUT_TEXT)
					{
						item.addEventListener(FocusEvent.FOCUS_IN, onInputTextFocusIn);
						item.addEventListener(FocusEvent.FOCUS_OUT, onInputTextFocusOut);
						item.addEventListener(Event.CHANGE, removeLeadingSpaces);
					}
					else
						item.addEventListener(FocusEvent.FOCUS_IN, onItemFocusIn);
				}
			}
		}
		
		public function validateSelection(e:HotKeyEvent):void
		{
			if (!vc.disabledList[vc.itemWithFocusIndex])
			{
				vc.itemWithFocus = vc.getItemByIndex(vc.itemWithFocusIndex);
				if (vc.itemWithFocus.visible && vc.itemWithFocus.alpha > 0)
					onItemFocusIn();
				else
				{
					if (_itemsSkipped < vc.numItems)
					{
						_itemsSkipped++;
						onHotKey(e);
					}
					else	
						_itemsSkipped--;
				}
			}
			else if (_itemsSkipped < vc.numItems)
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
			
			if (vc.itemDictionary)
			{
				l = vc.itemDictionary.length;
				for (var i:int = 0; i < l; i++)
				{
					item = vc.itemDictionary.getByIndex(i);
					if (item is TextField && item.hasEventListener(FocusEvent.FOCUS_IN))
					{
						item.removeEventListener(FocusEvent.FOCUS_IN, onInputTextFocusIn);
						item.removeEventListener(FocusEvent.FOCUS_OUT, onInputTextFocusOut);
						item.removeEventListener(Event.CHANGE, removeLeadingSpaces);
					}
					else if (item.hasEventListener(FocusEvent.FOCUS_IN))
						item.removeEventListener(FocusEvent.FOCUS_IN, onItemFocusIn);
					
					item.removeEventListener(UIEvent.VALUE_CHANGED, onValueChange);
					item.removeEventListener(MouseEvent.MOUSE_DOWN, _mu.onMouseDown);
				}
			}
		}
		
		public function onItemFocusIn(fe:FocusEvent = null):void
		{
			var vip:ViewItemProperties;
			var item:*;
			
			if (fe)
				item = vc.itemWithFocus = fe.currentTarget;
			else
				item = vc.itemWithFocus;
			
			if (item)
			{
				vc.itemWithFocusIndex = vc.getItemIndexByName(item.name);
				if (!vc.disabledList[vc.itemWithFocusIndex] && item.visible && item.alpha > 0)
				{
					Focus.show(item, vc.container);
					vip = vc.getItemPropsByName(item.name);
					if (vc.vp.AppControllerInstanceName)
						Plugins.callMethod(vc.vp.AppControllerInstanceName, PluginMethods.ON_FOCUS_IN, {itemWithFocus: item, focusEvent: fe});
				}
			}
		}
		
		private function onInputTextFocusIn(fe:FocusEvent):void
		{
			var vip:ViewItemProperties;
			var item:TextField;
			vip = _vpm.getItemPropsByName(vc.viewId, fe.currentTarget.name);
			
			if (vip)
				if (vip.type == ViewItemProperties.INPUT_TEXT)
				{
					FullScreen.restoreIfNotDesktop();
					item = vc.itemDictionary.getByKey(vip.name);
					item.setSelection(0, 999);
					vip.tText = Translate.text(vip.tText);
						
					if (item.text == vip.tText)
					{
						item.text = "";
						TextUtil.applyTextAttributes(item, vip.textAttributes, int(vip.width), int(vip.height));
					}
				}
			onItemFocusIn(fe);
		}
		
		private function onInputTextFocusOut(fe:FocusEvent):void
		{
			var vip:ViewItemProperties;
			var item:TextField;
			
			vip = _vpm.getItemPropsByName(vc.viewId, fe.currentTarget.name);
			
			if (vip)
				if (vip.type == ViewItemProperties.INPUT_TEXT)
				{
					item = vc.itemDictionary.getByKey(vip.name);
					if (item.text == "" && vip.tText)
						item.text = Translate.text(vip.tText);
				
					TextUtil.applyTextAttributes(item, vip.textAttributes, int(vip.width), int(vip.height));
					if (vip.voName)
						vc.vmg.copyViewItemToValueObject(vip, item);
				}
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
						if (vc.itemWithFocusIndex < vc.numItems - 1)
							vc.itemWithFocusIndex++;
						else
							vc.itemWithFocusIndex = 0;
						
						validateSelection(e);
						break;
					case "up": 
						if (vc.itemWithFocusIndex > 0)
							vc.itemWithFocusIndex--;
						else
							vc.itemWithFocusIndex = vc.numItems - 1;
						
						validateSelection(e);
						break;
					
					case "space": 
						if (getQualifiedClassName(vc.itemWithFocus).indexOf("Button") > -1)
							onTap(null, vc.itemWithFocus.name);
						else if (getQualifiedClassName(vc.itemWithFocus).indexOf("Toggle") > -1)
						{
							vc.itemWithFocus.value = !vc.itemWithFocus.value;
							vip = _vpm.getItemPropsByName(vc.viewId, vc.itemWithFocus.name);
							vc.vmg.copyViewItemToValueObject(vip, vc.itemDictionary.getByKey(vip.name));
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
			var cLip:ViewItemProperties;
			var cgp:ComponentGroupProperties;
			var cg:ComponentGroup;
			var contentContainer:*;
			
			if (uie.itemName)
				vip = _vpm.getItemPropsByName(vc.viewId, uie.itemName);
			else
				vip = _vpm.getItemPropsByName(vc.viewId, uie.target.name);
			
			if (vip)
			{
				if (vip.voName)
				{
					vc.vmg.vc.onViewChange(vip.name);
					vc.vmg.copyViewItemToValueObject(vip, uie.target);
					if (vip.type == ViewItemProperties.COMPONENT_GROUP || vip.type == ViewItemProperties.RADIO_GROUP)
					{
						cgp = Props.pr.componentGroupPresets.getPropsByName(vip.componentId);
						cg = vc.itemDictionary.getByKey(uie.itemName);
						contentContainer = cg.getChildAt(0);
						for (var i:int = 0; i < cgp.numComponents; i++)
							contentContainer.getChildAt(i).value = uie.value[i];
					}
				}
				onTap(null, vip.name);
			}
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
				if (vip && vip.action)
				{
					if (me)
						me.stopImmediatePropagation();
					
					if (!vip.onTapContainerNames)
					{
						containerNames = [];
						containerNames.push(vc.container.name);
					}
					else	
						containerNames = vip.onTapContainerNames.split(",");
					
					switch (vip.onTap)
					{
						case ViewItemProperties.UI_EVENT :
							uiEvent();
							break;
						case ViewItemProperties.MENU_CALL :
							menuCall();
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
						default :
							break;
					}
					
					function menuCall():void
					{
						vc.container.dispatchEvent(new UIEvent(UIEvent.MENU_SELECTION, 
																vc.container.name, vip.action));
					}
					
					function viewItemMethodCall():void
					{
						for (i = 0; i < containerNames.length; i++)
							_vu.callViewItemMethod(containerNames[i], vip.target, vip.action, vip.actionParams);
					}
					
					function PluginMethodCall():void
					{
						var dest:String;
						
						dest = vc.vp.AppControllerInstanceName;
						
						vc.initStatusMessage(vip.action);
						if (vip.voName)
							vc.vmg.copyViewItemToValueObject(vip, vc.itemDictionary.getByKey(vip.name));
						
						if (vip.actionParams)
							Plugins.callMethod(dest, vip.action, vip.actionParams);
						else
							Plugins.callMethod(dest, vip.action);
					}
					
					function containerMethodCall():void
					{
						for (i = 0; i < containerNames.length; i++)
							_vu.callViewContainerMethod(containerNames[i], vip.action, vip.actionParams);
					}
						
					function uiEvent():void
					{
						var dest:String;
						dest = vc.vp.AppControllerInstanceName;
						
						switch (vip.action)
						{
							case UIEvent.CLOSE :
								Props.uiController.closeView(vip.onTapContainerNames);
								break;
							case UIEvent.CREATE: 
							case UIEvent.UPDATE: 
								vc.setStatusMessage(vc.creatingMessage);
								if (vc.vmg.validate())
									if (vip.actionParams)
										Plugins.callMethod(dest, vip.action, vip.actionParams);
									else
										Plugins.callMethod(dest, vip.action);
								break;
							case UIEvent.ZOOM_IN: 
							case UIEvent.ZOOM_OUT: 
								containerNames = vip.onTapContainerNames.split(",");
								for (i = 0; i < containerNames.length; i++)
									_vu.zoom(null, vip.action, containerNames[i]);
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
								var c:ViewContainer = vc.vpm.getPropsById(containerNames[i]).container;
								for (i = 0; i < containerNames.length; i++)
									c.dispatchEvent(new UIEvent(vip.action, containerNames[i], vc.vp.menuName));
						}						
					}
				}
			}
		}
		
		private function onMouseOver(me:MouseEvent):void
		{
			var vip:ViewItemProperties;
			
			vip = _vpm.getItemPropsByName(vc.viewId, me.target.name);
			
			if (vip)
			{
				if (me.target.alpha > 0 && vip.tToolTip)
				{
					StageRef.stage.addEventListener(MouseEvent.MOUSE_OUT, onToolTipMouseOut, false, 0, true);
					ToolTip.show(Translate.text(vip.tToolTip), vc.vp.toolTipPreset);
				}
			}
		}
		
		private function onMouseDown(me:MouseEvent):void
		{
			var vip:ViewItemProperties;
			
			vip = _vpm.getItemPropsByName(vc.viewId, me.target.name);
			
			if (vip)
			{
				if (vip.onTapDownUiEvent)
				{
					switch (vip.onTapDownUiEvent)
					{
						case UIEvent.NATIVE_WINDOW_MOVE: 
							if (AirStatus.isNativeApplication)
								Plugins.callMethod(PluginClasses.AIR_PLUGIN, PluginMethods.NW_START_MOVE);
							break;
					}
				}
			}
		}
		
		private function onToolTipMouseOut(me:MouseEvent):void
		{
			ToolTip.hide();
			StageRef.stage.removeEventListener(MouseEvent.MOUSE_OUT, onToolTipMouseOut);
		}
		
		private function buttonSfx(me:MouseEvent):void
		{
			var vip:ViewItemProperties;
			var sfx:SoundFxProperties;
			var url:String;
			
			vip = _vpm.getItemPropsByName(vc.viewId, me.target.name);
			if (vip)
			{
				sfx = _pr.soundFxPresets.getPropsByName(vip.sFxPreset);
				if (sfx)
				{
					switch (me.type)
					{
						case MouseEvent.MOUSE_DOWN: 
							url = sfx.downUrl;
							break;
						case MouseEvent.MOUSE_OUT: 
							url = sfx.outUrl;
							break;
						case MouseEvent.CLICK: 
							url = sfx.tapUrl;
							break;
						case MouseEvent.MOUSE_OVER: 
							url = sfx.overUrl;
							break;
						case MouseEvent.MOUSE_UP: 
							url = sfx.upUrl
							break;
					}
				}
				if (url)
					SoundPlayer.loadAndPlay(url);
			}
		}
	}
}