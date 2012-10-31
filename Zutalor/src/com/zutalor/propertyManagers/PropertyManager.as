package com.zutalor.propertyManagers
{
	import com.zutalor.utils.gDictionary;
	/**
	 * ...
	 * @author Geoff Pepos
	 * 
	 */  
	
	public class PropertyManager
	{	
		private var _propertygDictionary:gDictionary;
		private var _PropertiesClass:Class;
		private var _defaultProperties:*;
				
		public function PropertyManager(PropertiesClass:Class) 
		{
			_PropertiesClass = PropertiesClass;
			_propertygDictionary = new gDictionary();
			_defaultProperties = new _PropertiesClass();
		}
					
		public function parseXML(xmlList:XMLList, nodeName:String = "props", childClass:Class = null, childXmlList:XMLList = null, childNodeName:String = null):void
		{	
			var xll:XMLList;
			if (!nodeName)
				xll = xmlList;
			else
				xll = xmlList[nodeName];
			
			for (var i:int = 0; i < xll.length(); i++) 
			{
				var prc:* = new _PropertiesClass();
				if (prc.parseXML(xll[i]))
				{
					_propertygDictionary.insert(prc.name, prc);
					if (childClass)
					{
						if (!prc.child)
							prc.child = new PropertyManager(childClass);
						
						prc.child.parseXML(xll[i][childNodeName], "");
					}
				}	
			}
			xll = null;
		}
				
		public function getPropsByName(name:String):*
		{
			if (_propertygDictionary.getByKey(name))
				return _propertygDictionary.getByKey(name) as _PropertiesClass;
			else
			{
				return null;
			}
		}
		
		public function getPropsByIndex(indx:int):*
		{
			return _propertygDictionary.getByIndex(indx) as _PropertiesClass;
		}
		
		public function deletePropsByIndx(indx:int):void
		{
			_propertygDictionary.deleteByIndex(indx);
		}
		
		public function deletePropsByName(name:String):void
		{
			_propertygDictionary.deleteByKey(name);
		}
		
		public function get length():int
		{
			return _propertygDictionary.length;
		}
		
		public function getChildIndexByName(name:String):*
		{
			return _propertygDictionary.getIndexByKey(name);
		}
		
		public function getChildByIndex(index:int):*
		{
			var x:* = _propertygDictionary.getByIndex(index);
			
			if (x)
				return x.child;
			else
				return null;
		}
		
		public function getChildByName(name:String):*
		{
			var x:* = _propertygDictionary.getByKey(name); 
			
			if (x)
				return x.child;
			else
				return null;
		}
	}
}