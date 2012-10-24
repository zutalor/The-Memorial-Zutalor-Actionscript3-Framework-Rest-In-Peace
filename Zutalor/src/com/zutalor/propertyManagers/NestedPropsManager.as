package com.zutalor.propertyManagers 
{

	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class NestedPropsManager 
	{
		private var _pm:PropertyManager;	
		private var _ipm:PropertyManager;
		private var _NodePropertiesClass:Class;
		private var _curItem:String;
		private var _curId:String;
		private var _curItemProps:*;
		private var _curProps:*;
		
		public function NestedPropsManager() // only handles one extra node, GP:Implement rest ... if needed later.
		{

		}
		
		public function parseXML(NodePropertiesClass:Class, NestedNodePropertiesClass:Class, propsXml:XMLList, propsName:String, itemPropsXml:XMLList, itemPropsName:String):void
		{
			if (!_pm)
				_pm = new PropertyManager(NodePropertiesClass);

			_pm.parseXML(propsXml, propsName, NestedNodePropertiesClass, itemPropsXml, itemPropsName);
			_NodePropertiesClass = NodePropertiesClass;
		}		
									
		public function getPropsById(id:String):*
		{
			return _pm.getPropsByName(id) as _NodePropertiesClass;
		}
		
		public function getPropsByIndex(index:int):*
		{
			return _pm.getPropsByIndex(index) as _NodePropertiesClass;
		}				
		
		public function getItemPropsByIndex(id:String, index:int):*
		{
			_ipm = _pm.getChildByName(id);
			return _ipm.getPropsByIndex(index);
		}
				
		public function getItemPropsByName(id:String, itemName:String):*
		{
			_ipm = _pm.getChildByName(id);
			if (_ipm)
				return _ipm.getPropsByName(itemName);
			else
				return null;
		}
		
		public function getItemIndexByName(id:String, itemName:String):int
		{
			_ipm = _pm.getChildByName(id);
			if (_ipm)
				return _ipm.getChildIndexByName(itemName);
			else
				return -1;
		}			
		
		public function getNumItems(id:String):int
		{
			_ipm = _pm.getChildByName(id) as PropertyManager;
			if (_ipm)
				return _ipm.length;
			else
				return 0;
		}		
	}
}