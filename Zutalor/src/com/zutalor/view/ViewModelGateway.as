package com.zutalor.view  
{
	import com.zutalor.containers.ScrollingContainer;
	import com.zutalor.containers.StandardContainer;
	import com.zutalor.media.VideoPlayer;
	import com.zutalor.plugin.constants.PluginMethods;
	import com.zutalor.plugin.Plugins;
	import com.zutalor.properties.ApplicationProperties;
	import com.zutalor.properties.MediaProperties;
	import com.zutalor.properties.ViewItemProperties;
	import com.zutalor.propertyManagers.NestedPropsManager;
	import com.zutalor.propertyManagers.Presets;
	import com.zutalor.propertyManagers.Props;
	import com.zutalor.text.TextUtil;
	import com.zutalor.text.Translate;
	import com.zutalor.view.ViewController;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ViewModelGateway
	{
		public static const FORMAT_TIME:String = "time";
		
		public var vc:ViewController;
		
		private var _vpm:NestedPropsManager;
		private var _ap:ApplicationProperties;
		private var _pr:Presets;
		
		private static var _cachedVOName:String;
		private static var _valueObject:*;
		
		public function ViewModelGateway(viewController:ViewController) 
		{
			vc = viewController;
			_vpm = Props.views;
			_ap = ApplicationProperties.gi();
			_pr = Presets.gi();
		}

		public function setItemInitialValue(vip:ViewItemProperties):void
		{
			var item:*;
			
			item = vc.itemDictionary.getByName(vip.name); 
			switch (vip.type)
			{
				case ViewItemProperties.INPUT_TEXT :
					if (vip.tText)
						item.text = Translate.text(vip.tText);
					
					TextUtil.applyTextAttributes(item, vip.textAttributes, int(vip.width), int(vip.height));			
					break;
				case ViewItemProperties.PROPERTY :
					if (vip.voName)
					{
						_valueObject = Plugins.callMethod(vc.vp.controllerClassInstanceName, PluginMethods.GET_VALUE_OBJECT, { voName:vip.voName } );
						_valueObject[vip.name] = vip.data;
					}
					break;
				case ViewItemProperties.SLIDER :
				case ViewItemProperties.STEPPER :
				case ViewItemProperties.COMPONENT_GROUP : 
				case ViewItemProperties.RADIO_GROUP : 
					if (vip.voName)
					{
						_valueObject = Plugins.callMethod(vc.vp.controllerClassInstanceName, PluginMethods.GET_VALUE_OBJECT, { voName:vip.voName } );
						item.value = _valueObject[vip.name];
					}
					break;
			}	
			function onTranslateComplete(data:*):void
			{
				
			}
		}
		
		public function setAllInitialValues():void
		{
			var vip:ViewItemProperties;
									
			for (var i:int = 0; i < vc.numViewItems; i++)
			{
				vip = _vpm.getItemPropsByIndex(vc.viewId, i);
				setItemInitialValue(vip);
				vc.onViewChange(vip.name);
			}
		}
		
		public function validate():Boolean
		{
			var vip:ViewItemProperties;
			var valid:Boolean;
			var value:*;
			
			valid = true;
			
			for (var i:int = 0; i < vc.numViewItems; i++)
			{
				vip = _vpm.getItemPropsByIndex(vc.viewId, i)
	
				switch (vip.type)
				{
					case ViewItemProperties.INPUT_TEXT :
					case ViewItemProperties.LIST :
					case ViewItemProperties.COMBOBOX :
						if (vip.required) 
						{
							if (_valueObject[vip.name] == "" || _valueObject[vip.name] == vip.tText || _valueObject[vip.name] == vip.text)
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
						else if (_valueObject[vip.name] == vip.tText || _valueObject[vip.name] == vip.text)
							_valueObject[vip.name] = "";
						
						break;

					case ViewItemProperties.COMPONENT_GROUP :
					case ViewItemProperties.RADIO_GROUP :
						
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
				}
				if (!valid)
					break;
			}
			if (!valid)
			{
				if (vip.tError)
					vc.setStatusMessage(Translate.text(vip.tError));
				else
					vc.setStatusMessage("Please correct empty fields");
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
			if (vip.voName)
			{
				_valueObject = Plugins.callMethod(vc.vp.controllerClassInstanceName, PluginMethods.GET_VALUE_OBJECT, { voName:vip.voName } );
				if (_valueObject)
				{
					switch (vip.type)
					{
						case ViewItemProperties.LIST :
						case ViewItemProperties.COMBOBOX :
							if (item.selectedItem)
								_valueObject[vip.name] = item.selectedItem;
							else
								_valueObject[vip.name] = null;
							break;
						case ViewItemProperties.INPUT_TEXT :	
						case ViewItemProperties.LABEL :	
							_valueObject[vip.name] = item.text;
							break;

							_valueObject[vip.name] = item.value;
							break;
						case ViewItemProperties.VIDEO :
							item.stop();
							item.visible = false;
							break;
						case ViewItemProperties.TOGGLE :
						case ViewItemProperties.SLIDER :
						case ViewItemProperties.TEXT_BUTTON :
						case ViewItemProperties.BUTTON :
						case ViewItemProperties.STEPPER :
						case ViewItemProperties.COMPONENT_GROUP :
						case ViewItemProperties.RADIO_GROUP :
								_valueObject[vip.name] = item.value;
								break;
					}
				}
				else
					throw new Error("View Model Gateway: valueObject not found: " + vip.voName);
			}
		}
		
		public function copyValueObjectToViewItem(vip:ViewItemProperties, item:*):void
		{
			var c:ScrollingContainer;
			var dataProvider:Array;
			
			if (vip.voName)
			{
				_valueObject = Plugins.callMethod(vc.vp.controllerClassInstanceName, PluginMethods.GET_VALUE_OBJECT, { voName:vip.voName } );
				if (_valueObject)
				{
						switch (vip.type)
						{	
							case ViewItemProperties.INPUT_TEXT :
							case ViewItemProperties.LABEL :
								if (_valueObject[vip.name])
								{
									switch (vip.format)
									{
										case FORMAT_TIME :
											item.text = TextUtil.formatTime(_valueObject[vip.name]);
											break;
										default :
											item.text = _valueObject[vip.name];
									}
									TextUtil.applyTextAttributes(item, vip.textAttributes, int(vip.width), int(vip.height));
								}
								break;
							case ViewItemProperties.LIST :	
							case ViewItemProperties.COMBOBOX :	
								item.selectedItem = _valueObject[vip.name]
								if (vip.dataProvider)
								{
									if (_valueObject[vip.dataProvider])
										item.dataProvider = _valueObject[vip.dataProvider];
								}
								break;
							case ViewItemProperties.HTML :
								var t:TextField = item;
								vc.itemDictionary.addOrReplace(vip.name, t);
								TextUtil.applyStylesheet(t, _ap.defaultStyleSheetName, int(vip.width));
								if (_valueObject[vip.name] != null)
								{
									t.htmlText = _valueObject[vip.name];
									TextUtil.smoothHtmlBitmaps(t);
								}
								break;
							case ViewItemProperties.TOGGLE :
							case ViewItemProperties.SLIDER :
							case ViewItemProperties.TEXT_BUTTON :
							case ViewItemProperties.BUTTON :
							case ViewItemProperties.STEPPER :
							case ViewItemProperties.COMPONENT_GROUP :
							case ViewItemProperties.RADIO_GROUP :

								item.value = _valueObject[vip.name];
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
						}		
					}
			}
		}
	}
}