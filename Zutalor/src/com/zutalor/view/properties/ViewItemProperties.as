package com.zutalor.view.properties
{
	import com.zutalor.interfaces.IProperties;
	import com.zutalor.path.Path;
	import com.zutalor.properties.PropertiesBase;
	import com.zutalor.utils.MapXML;

	/**
	 * ...
	 * @author Geoff Pepos
	 */
	
	public class ViewItemProperties extends PropertiesBase implements IProperties
	{
		// item type
		public static const STATUS:String = "status";
		public static const PROPERTY:String = "property";
		
		// gesture types
		public static const APP_STATE_CHANGE:String = "appStateChange";
		public static const UI_EVENT:String = "uiEvent";
		public static const URL:String = "url";
		public static const PLUGIN_METHOD:String = "pluginMethodCall";
		public static const CONTAINER_METHOD:String = "containerMethodCall";
		public static const VIEWITEM_METHOD:String = "viewItemMethodCall";
		
		public var type:String;
		public var presetId:String;
		
		public var tKey:String;
		public var text:String;
		
		public var className:String;
		public var viewId:String;
		public var data:String;
	
		public var voName:String;
		public var hidden:Boolean;
		
		public var format:String;
		public var textAttributes:String;
		public var styleSheetName:String;
		
		public var width:String; // yes string because it can be either "auto" or a number.
		public var height:String; // same as above
		public var scale:Number;
		public var align:String;
		public var tabIndex:int;
		
		public var url:String;
		public var path:String;

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
		public var parent:String;
		
		public var validate:String;
		public var required:Boolean;
		public var tError:String;
		public var draggable:Boolean;

		public var onTap:String;
		public var tapTarget:String;
		public var tapAction:String;
		public var tapActionOptions:String;
		public var tapContainerNames:String;
		
		public var onPress:String;
		public var pressTarget:String;
		public var pressAction:String;
		public var pressActionOptions:String;
		
		public var hotkey:String;
		
		public var mediaPreset:String;
		public var playlistName:String;
		
		public var transitionPreset:String;
		public var transitionDelay:Number;

		public var filterPreset:String;
		public var maskId:String;
		public var tMeta:String; // use for whatever. Runs through "translate" text.
		
		public function ViewItemProperties() {}
					
		override public function parseXML(xml:XML):Boolean
		{
			MapXML.attributesToClass(xml , this);

			if (!alpha)
				alpha = 1;
			
			if (String(xml.@path))
				url = Path.getPath(String(xml.@path)) + xml.@url;
			else
				url = xml.@url;
				
			if (text)
				text = text.split("\\n").join("\n");
				
			return true;
		}
	}
}