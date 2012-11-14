package com.zutalor.properties 
{
	import com.zutalor.containers.ViewContainer;
	import com.zutalor.interfaces.IProperties;
	import com.zutalor.propertyManagers.PropertyManager;
	import com.zutalor.propertyManagers.Props;
	import com.zutalor.utils.MapXML;
	import flash.display.DisplayObject;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ViewProperties extends PropertiesBase implements IProperties
	{
		public static const CONTAINER_SCROLLING:String = "scrolling";
		public static const CONTAINER_BASIC:String = "basic";
		public static const CONTAINER_MASKED:String = "masked";
		public static const CONTAINER_PARALLAX:String = "parallax";
		
		public var uiControllerInstanceName:String;
		public var initialMethod:String;
		public var initialMethodParams:String;
		public var toolTipPreset:String;
		public var styleSheetName:String;
		public var visibleOnLoad:Boolean;
		public var contentPersists:Boolean;
		public var resizeMode:String;
		public var containerType:String
		public var width:int;
		public var height:int;
		public var hPad:int;
		public var vPad:int;
		public var align:String;
		public var x:Number;
		public var y:Number;
		public var z:Number;
		public var vx:Number;
		public var vy:Number;
		public var vz:Number;
		public var rotation:Number;
		public var rotX:Number;
		public var rotY:Number;
		public var rotZ:Number;
		public var rotVx:Number;
		public var rotVy:Number;
		public var gravity:Number;
		public var scale:Number
		public var alpha:Number = 1;
		public var blendMode:String;	
		public var transitionPreset:String;
		public var mediaPreset:String;
		public var menuName:String;
		public var filterPreset:String;		
		public var hScrollBarSliderId:String;
		public var vScrollBarSliderId:String;
		public var autoAdjustThumbSize:Boolean;
		public var container:ViewContainer;
		
		override public function parseXML(xml:XML):Boolean
		{	
			MapXML.attributesToClass(xml , this); // map the properties
			name = name.toLowerCase();
			if (!styleSheetName)
				styleSheetName = Props.ap.defaultStyleSheetName;
				
			return true;
		}
	}	
}