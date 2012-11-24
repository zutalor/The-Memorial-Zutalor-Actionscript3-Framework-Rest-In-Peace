package com.zutalor.plugin
{
	import com.zutalor.utils.gDictionary;
	import com.zutalor.utils.ShowError;
	import flash.utils.getQualifiedClassName;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Plugins
	{	
		
		private static var _classes:gDictionary;
		private static var _instances:gDictionary;
		private static var _initialized:Boolean;
				
		public static function registerClass(Klass:Class, name:String = null):String
		{
			var className:String;
			
			checkIfInitialized();
			
			if (name)
				className = name;
			else
				className = getClassName(Klass);		
			
			_classes.insert(className, Klass);
			return className;
		}

		public static function getClassName(Klass:Class):String
		{
			var p:int;
			var fullClassName:String;

			fullClassName = getQualifiedClassName(Klass);		
			
			p = fullClassName.indexOf("::");
			
			if (p > 0)
				return fullClassName.slice(p + 2); 
			else
				return fullClassName;
		}
		
		public static function getClass(className:String):Class
		{
			var Klass:Class;
			
			Klass = _classes.getByKey(className);
			if (!Klass)
				ShowError.fail(Plugins, "no class registered for: " + className);
			
			return Klass;	
		}
		
		public static function getInstance(classInstanceName:String):*
		{
			var instance:*;
			
			instance = _instances.getByKey(classInstanceName);
			
			if (instance)
				return instance;
			else
				ShowError.fail(Plugins,"Plugins, no instance registered: " + classInstanceName);
		}
		
		public static function getNewInstance(className:String):*
		{
			var Klass:Class;
			Klass = _classes.getByKey(className);

			if (!Klass)
				ShowError.fail(Plugins,"No class registered for: " + className);
			else
				return new Klass;
				
		}
		
		private static function createCachedInstance(instanceName:String, className:String):void
		{
			checkIfInitialized();
			_instances.insert(instanceName, getNewInstance(className));			
		}
		
		public static function registerClassAndCreateCachedInstance(Klass:Class, instanceName:String = null, isStatic:Boolean = false):void
		{
			checkIfInitialized();

			instanceName = registerClass(Klass, instanceName);
			
			
			if (!isStatic)
				_instances.insert(instanceName, getNewInstance(instanceName));
			else
				_instances.insert(getClassName(Klass), Klass);
		}
				
		public static function callMethod(classInstanceName:String, methodName:String, params:Object = null):*
		{
			if (classInstanceName)
			{
				if (params != null)
					return _instances.getByKey(classInstanceName.toLowerCase())[methodName](params);
				else
					return _instances.getByKey(classInstanceName)[methodName]();
			}
		}
		
		private static function getMethod(classInstanceName:String, methodName:String):*
		{
			return _instances.getByKey(classInstanceName)[methodName];
		}
				
		private static function checkIfInitialized(): void
		{
			if (!_initialized)
			{
				_classes = new gDictionary;
				_instances = new gDictionary;
				_initialized = true;
			}
		}
	}
}