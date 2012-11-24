	public interface IPlugins
	{	
		function registerClass(Klass:Class, name:String = null):String
		function getClassName(Klass:Class):String
		function getClass(className:String):Class
		function getInstance(classInstanceName:String):*
		function getNewInstance(className:String):*
		function createCachedInstance(instanceName:String, className:String):void
		public function registerClassAndCreateCachedInstance(Klass:Class, instanceName:String = null, isStatic:Boolean = false):void
		function callMethod(classInstanceName:String, methodName:String, params:Object = null):*
	}