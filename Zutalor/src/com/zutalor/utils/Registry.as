package com.zutalor.utils 
{
	import com.gskinner.utils.IDisposable;
	import com.zutalor.utils.gDictionary;
	import flash.utils.getQualifiedSuperclassName;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Registry implements IDisposable
	{
		private var _Klass:Class;
		private var _superClassName:String;
		private var _dictionary:gDictionary;
		
		public function Registry(Klass:Class)
		{
			_Klass = Klass;
			init();
		}
		
		private function init():void
		{
			 _dictionary = new gDictionary();
			_superClassName = getQualifiedSuperclassName(_Klass);
		}
		
		public function dispose():void
		{
			_dictionary.dispose();
			_dictionary = null;
		}
		
		public function retrieve(id:String=null):*
		{
			return _dictionary.getByKey(id);
		}
		
		public function register(id:String, item:*):void
		{
			if (getQualifiedSuperclassName(item) != _superClassName)
				_dictionary.insert(id, item);
			else
				ShowError.fail(Registry, "Cannot register [" + id + "] " + item + " class should be " + _Klass);
		}	
		
		public function unregister(id:String):void
		{
			_dictionary.deleteByKey(id);
		}				
	}
}