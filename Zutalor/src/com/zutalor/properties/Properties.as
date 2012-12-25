package com.zutalor.properties
{
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Properties
	{
		private static var _registry:Vector.<PresetRegistryProperties>;
		
		public static function register(propertyClass:*, nodeId:String, childNodeId:String = null, alternateFunction:Function = null):void
		{
			if (!_registry)
				_registry = new Vector.<PresetRegistryProperties>;
	
			var p:PresetRegistryProperties = new PresetRegistryProperties();
			
			p.propertyClass = propertyClass;
			p.nodeId = nodeId;
			p.childNodeId = childNodeId;
			p.alternateFunction = alternateFunction;
			
			_registry.push(p);
		}
		
		public static function parseXML(xml:XML):void
		{
			var l:int;
			var func:Function;
			var p:PresetRegistryProperties;
			
			l = _registry.length;
			
			for (var i:int = 0; i < l; i++)
			{
				p = _registry[i];
				
				if (p.alternateFunction != null)
					func = p.alternateFunction;
				else
					func = p.propertyClass.registerPresets;
			
				func( { xml:xml, nodeId:p.nodeId, childNodeId:p.childNodeId } );
			}
		}
	}
}