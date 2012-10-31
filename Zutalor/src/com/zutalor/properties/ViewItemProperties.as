package com.zutalor.properties  
{
	import com.zutalor.interfaces.IProperties;
	import com.zutalor.utils.MapXML;
	import com.zutalor.utils.Path;

	/**
	 * ...
	 * @author Geoff Pepos
	 */
	
	public class ViewItemProperties extends PropertiesBase implements IProperties
	{	
		// item type
		public static const INPUT_TEXT:String = "inputText";
		public static const LABEL:String = "label";
		public static const STATUS:String = "status";
		public static const TOGGLE:String = "toggle";
		public static const COMPONENT_GROUP:String = "componentGroup";
		public static const RADIO_GROUP:String = "radioGroup";
		public static const SLIDER:String = "slider";
		public static const TEXT_BUTTON:String = "textButton";
		public static const BUTTON:String = "button";
		public static const STEPPER:String = "stepper";	
		public static const LIST:String = "list";
		public static const COMBOBOX:String = "comboBox";
		public static const SLIDE_SHOW:String = "slideShow";
		public static const FLIPBOOK:String = "flipbook";
		public static const VIDEO:String = "video";
		public static const BASIC_VIDEO:String = "basicVideo";
		public static const YOUTUBE:String = "youtube";
		public static const AUDIO:String = "audio";
		public static const HTML:String = "html"
		public static const WEB:String = "web"
		public static const TWITTER:String = "twitter";
		public static const GRAPHIC:String = "graphic";
		public static const CAMERA:String = "camera";
		public static const PLAYLIST:String = "playlist";
		public static const EMBED:String = "embed";
		public static const PROPERTY:String = "property";
		
		// tap types
		public static const MENU_CALL:String = "menuCall";
		public static const UI_EVENT:String = "uiEvent";
		public static const PLUGIN_METHOD:String = "pluginMethodCall";
		public static const CONTAINER_METHOD:String = "containerMethodCall";
		public static const VIEWITEM_METHOD:String = "viewItemMethodCall";	
		
		public var type:String;
		public var voName:String;
		public var hidden:Boolean;
		public var excludeFromDisplayList:Boolean;
		public var tText:String;
		public var text:String;
		public var format:String;
		public var textAttributes:String;
		public var data:String;
		public var dataProvider:String;
		public var width:String; // yes string because it can be either "auto" or a number.
		public var height:String; // same as above
		public var tabIndex:int;
		public var align:String;
		public var x:Number;
		public var y:Number;
		public var hPad:Number;
		public var vPad:Number;
		public var vx:Number;
		public var vy:Number;
		public var rotation:Number;
		public var rotationX:Number;
		public var rotationY:Number;
		public var rotationZ:Number;
		public var alpha:Number;
		public var validate:String;
		public var required:Boolean;
		public var tError:String;

		public var onTap:String;
		public var target:String;
		public var action:String;
		public var actionParams:String;		
		public var onTapDownUiEvent:String;
		public var onTapContainerNames:String;
		
		public var componentId:String;		
		public var tToolTip:String;
		public var hotkey:String;
		public var url:String;
		public var path:String;
		public var mediaPreset:String;
		public var sFxPreset:String;
		public var playlistName:String;
		public var graphicId:String;
		public var textureName:String;
		public var className:String;
		public var transitionPreset:String;
		public var transitionDelay:Number;
		public var scrollPreset:String;
		public var containerX:Number;
		public var containerY:Number;
		public var filterPreset:String;
		public var maskGid:String;
		public var tMeta:String; // use for whatever. Runs through "translate" text.
					
		override public function parseXML(xml:XML):Boolean
		{
			
			MapXML.attributeToClass(xml , this); // map the properties

			if (!alpha)
				alpha = 1;	
			
			if (String(xml.@path))
				url = Path.getPath(String(xml.@path)) + xml.@url;
			else
				url = xml.@url;

			if (tToolTip)
				tToolTip = tToolTip.split("\\n").join("\n");
				
			if (tText)
				tText = tText.split("\\n").join("\n");	
							
				
			return true;	
		}
	}
}