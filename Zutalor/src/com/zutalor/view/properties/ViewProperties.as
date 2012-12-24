package com.zutalor.view.properties 
{
	import com.zutalor.application.Application;
	import com.zutalor.containers.ViewContainer;
	import com.zutalor.interfaces.IProperties;
	import com.zutalor.properties.PropertiesBase;
	import com.zutalor.utils.MapXML;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ViewProperties extends PropertiesBase implements IProperties
	{
		public var uiControllerInstanceName:String;
		public var initialMethod:String;
		public var initialMethodParams:String;
		public var toolTipPreset:String;
		public var styleSheetName:String;
		public var contentPersists:Boolean;
		public var resizeMode:String;
		public var width:int;
		public var height:int;
		public var hPad:int;
		public var vPad:int;
		public var align:String;
		public var x:Number = 0;
		public var y:Number = 0;
		public var z:Number = 0;
		public var vx:Number = 0;
		public var vy:Number = 0;
		public var vz:Number = 0;
		public var rotation:Number = 0;
		public var rotX:Number = 0;
		public var rotY:Number = 0;
		public var rotZ:Number = 0;
		public var rotVx:Number = 0;
		public var rotVy:Number = 0;
		public var gravity:Number = 0;
		public var scale:Number = 0
		public var alpha:Number = 1;
		public var blendMode:String;	
		public var transitionPreset:String;
		public var mediaPreset:String;
		public var appState:String;
		public var filterPreset:String;		
		public var container:ViewContainer;
		
		override public function parseXML(xml:XML):Boolean
		{	
			MapXML.attributesToClass(xml , this); // map the properties
			name = name.toLowerCase();
			if (!styleSheetName)
				styleSheetName = Application.settings.defaultStyleSheetName;
				
			return true;
		}
	}	
}