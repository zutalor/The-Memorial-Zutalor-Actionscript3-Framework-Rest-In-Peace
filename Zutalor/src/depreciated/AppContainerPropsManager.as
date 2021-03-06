﻿package depreciated
{
	import com.zutalor.containers.base.ContainerObject;
	import com.zutalor.properties.ContainerProperties;
	import com.zutalor.utils.Singleton;
	/**
	/**
	 * 
	 * @author ...
	 */
	public class AppContainerPropsManager

	{	
		private var cp:ContainerObjectProperties;	
		private var cpm:PropertyManager;
		
		private static var _appContainerPropsManager:AppContainerPropsManager;
			
		public function AppContainerPropsManager() 
		{
			Singleton.assertSingle(AppContainerPropsManager);
		}
		
		public static function gi():AppContainerPropsManager
		{
			if (!_appContainerPropsManager)
				_appContainerPropsManager = new AppContainerPropsManager();
			
			return _appContainerPropsManager;
		}		
		
		public function parseXML(xmlList:XMLList, nodeName:String="props"):void
		{
			if (!cpm)
			{
				cpm = new PropertyManager(ContainerProperties);
				cpm.parseXML(xmlList, nodeName);
			}
		}
		
		public function getContainerByName(name:String):*
		{
			return cpm.getPropsByName(name).container;
		}
		
		public function getContainerByIndex(index:int):ContainerObject
		{
			return cpm.getPropsByIndex(index).container;
		}		
		
		public function getContainerPropsByName(name:String):ContainerObjectProperties
		{
			return cpm.getPropsByName(name);
		}
		
		public function getContainerPropsByIndex(index:int):ContainerObjectProperties
		{
			return cpm.getPropsByIndex(index);
		}
		
		public function get numContainers():int
		{
			return cpm.length;
		}
	}
}