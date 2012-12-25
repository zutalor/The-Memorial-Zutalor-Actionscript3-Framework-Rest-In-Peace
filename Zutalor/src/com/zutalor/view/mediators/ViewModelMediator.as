package com.zutalor.view.mediators  
{
	import com.zutalor.components.base.Component;
	import com.zutalor.components.group.ComponentGroup;
	import com.zutalor.components.group.RadioGroup;
	import com.zutalor.containers.ViewContainer;
	import com.zutalor.plugin.constants.PluginMethods;
	import com.zutalor.plugin.Plugins;
	import com.zutalor.application.ApplicationProperties;
	import com.zutalor.properties.NestedPropsManager;
	import com.zutalor.translate.Translate;
	import com.zutalor.utils.ShowError;
	import com.zutalor.view.controller.ViewController;
	import com.zutalor.view.properties.ViewItemProperties;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ViewModelMediator
	{
		public static const FORMAT_TIME:String = "time";
		
		public var vc:ViewController;
		private var _vpm:NestedPropsManager;
		private static var _cachedVOName:String;
		private static var _valueObject:*;
		
		public function ViewModelMediator(viewController:ViewController) 
		{
			vc = viewController;
			_vpm = ViewController.presets;
		}

		public function setItemInitialValue(vip:ViewItemProperties):void
		{
			var item:*;
			var ViewItemClass:Class
			
			ViewItemClass = Plugins.getClass(vip.type);
			item = vc.container.getChildByName(vip.name);
			
			if (vip.voName)
			{
				_valueObject = Plugins.callMethod(vc.vp.uiControllerInstanceName, PluginMethods.GET_VALUE_OBJECT, { voName:vip.voName } );
				item.value = _valueObject[vip.name];
			}			
		}
		
		public function setAllInitialValues():void
		{
			var vip:ViewItemProperties;
									
			for (var i:int = 0; i < vc.numViewItems; i++)
			{
				vip = _vpm.getItemPropsByIndex(vc.viewId, i);
				if (vip.voName)
				{
					setItemInitialValue(vip);
					vc.onViewChange(vip.name);
				}
			}
		}
		
		public function validate():Boolean
		{
			var vip:ViewItemProperties;
			var valid:Boolean;
			var value:*;
			var ViewItemClass:Class;
			
			valid = true;
			
			for (var i:int = 0; i < vc.numViewItems; i++)
			{
				vip = _vpm.getItemPropsByIndex(vc.viewId, i)
				ViewItemClass = Plugins.getClass(vip.type);
				
				switch (ViewItemClass)
				{
					case ComponentGroup :
					case RadioGroup :
						if (vip.required)
							if (_valueObject[vip.name])
							{
								valid = false;
								value = _valueObject[vip.name];
								for (var ii:int = 0; ii < value.length; ii++)
									if (value[ii])
									{
										valid = true;
										break;
									}
							}	
						break;
					case Component :
						if (vip.required) 
						{
							if (_valueObject[vip.name] == "" || _valueObject[vip.name] == vip.text || _valueObject[vip.name] == vip.text)
							{
								setItemInitialValue(vip);
								valid = false;
							}
						}
						else if (vip.validate == "email")
						{
							if (!validateEmail(_valueObject[vip.name]))
								valid = false;
						}
						else if (_valueObject[vip.name] == vip.text || _valueObject[vip.name] == vip.text)
							_valueObject[vip.name] = "";
						
						break;

				}
				if (!valid)
					break;
			}
			if (!valid)
			{
				if (vip.tError)
					vc.setStatus(Translate.text(vip.tError));
				else
					vc.setStatus("Please correct empty fields");
			}
			
			return valid;
		}
		
		public function validateEmail(e:String):Boolean
		{
			if(e.length >= 7) {
				if(e.indexOf("@") > 0) {
					if((e.indexOf("@") + 2) < e.lastIndexOf(".")) {
						if (e.lastIndexOf(".") < (e.length - 2)) {
							return true; 
						}
					}
				}
			}
			return false;
		}	
		
		public function copyViewItemToValueObject(vip:ViewItemProperties, item:*):void
 		{
			var ViewItemClass:Class;
		
			if (vip.voName)
			{
				ViewItemClass = Plugins.getClass(vip.type);
				_valueObject = Plugins.callMethod(vc.vp.uiControllerInstanceName, PluginMethods.GET_VALUE_OBJECT, { voName:vip.voName } );
				if (_valueObject)
				{
					if (ViewItemClass == Component)
						_valueObject[vip.name] = item.value;
				}
				else
					ShowError.fail(ViewModelMediator,"valueObject not found: " + vip.voName);
			}
		}
		
		public function copyValueObjectToViewItem(vip:ViewItemProperties, item:Component):void
		{
			var c:ViewContainer;
			var dataProvider:Array;
			var ViewItemClass:Class;
			
			if (vip.voName)
			{
				_valueObject = Plugins.callMethod(vc.vp.uiControllerInstanceName, PluginMethods.GET_VALUE_OBJECT, { voName:vip.voName } );
				ViewItemClass = Plugins.getClass(vip.type);							
				item.value = _valueObject[vip.name];
			}
		}
	}
}

/*
						case ViewItemTypes.LIST :	
						case ViewItemTypes.COMBOBOX :	
							item.selectedItem = _valueObject[vip.name]
							if (vip.dataProvider)
							{
								if (_valueObject[vip.dataProvider])
									item.dataProvider = _valueObject[vip.dataProvider];
							}
							break;
							
						case ViewItemProperties.HTML :
							var t:TextField = item;
							vc.itemDictionary.insert(vip.name, t);
							TextUtil.applyStylesheet(t, _ap.defaultStyleSheetName, int(vip.width));
							if (_valueObject[vip.name] != null)
							{
								t.htmlText = _valueObject[vip.name];
								TextUtil.smoothHtmlBitmaps(t);
							}
							break;
						
						case ViewItemProperties.VIDEO :
							var v:VideoPlayer;
							var mpp:MediaProperties;
							if (_valueObject[vip.name])
							{
								mpp = _pr.mediaPresets.getPropsByName(vip.mediaPreset);
								item.load(_valueObject[vip.name], mpp.volume, mpp.loopCount, mpp.loopDelay);
								
								if (mpp.autoPlay)
									item.play(mpp.mediaFadeIn, mpp.audioFadeIn, mpp.fadeOut, mpp.startDelay);
								
								item.x = vip.x;
								item.visible = true;
							}
								*/