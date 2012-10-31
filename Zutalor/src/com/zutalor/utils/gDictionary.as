package com.zutalor.utils 
{
	/**
	 * ...
	 * @author Geoff Pepos
	 * 
	 */
	public class gDictionary
	{
		private var _key:Vector.<Object>;
		private var _value:Vector.<Object>;
		private var _initialSize:int;
		
		public function gDictionary(initialSize:int = 10) 
		{
			_initialSize = initialSize;
			clear();
		}
		
		private function clear():void
		{
			_key = new Vector.<Object>;
			_value = new Vector.<Object>;
			
			//_key.length = _initialSize;
			//_value.length = _initialSize;
		}
				
		public function dispose():void
		{
			_key = null;
			_value = null;
		}
		
		public function insert(key:Object, obj:*, newkey:Object=null):void
		{
			var i:int;
			
			if (key is String)
				key = key.toLowerCase();
			
			i = _key.indexOf(key);
			
			if (i == -1)
				i = _key.indexOf(null)
					if (i == -1)
						i = _key.length;
				
			_value[i] = obj;
			
			if (newkey)
			{
				if (newkey is String)
					newkey = newkey.toLowerCase();
				
				_key[i] = newkey;
			}
			else
				_key[i] = key;
		}

		public function deleteByKey(key:Object):void
		{
			var i:int;
			
			if (key is String)
				key = key.toLowerCase();
			
			i = _key.indexOf(key);
			
			if (i != -1)
			{
				_value[i] = null;
				_key[i] = null;
				_value.splice(i, 1);
				_key.splice(i, 1);
			}
		}
		
		public function deleteByIndex(index:int):void
		{			
			if (index < _key.length)
			{
				_value[index] = null;
				_key[index] = null;
				_value.splice(index, 1);
				_key.splice(index, 1);
			}
		}

		public function getByKey(key:Object):*
		{
			var i:int;
			
			if (!key)
				return null;
			else
				if (key is String)
					key = key.toLowerCase();
				
				i = _key.indexOf(key);
				
				if (i != -1)
					return _value[i];
				else
					return null;
		}
		
		public function getByIndex(index:int):*
		{
			if (index < _key.length && index >= 0)
				return _value[index];
			else
				return null;
		}
		
		public function getKeyByIndex(index:int):*
		{
			if (index < _key.length && index > -1)
				return _key[index];
			else
				return null;
		}
		
		public function getIndexByKey(key:Object):int
		{
			if (key)
			{
				if (key is String)
					_key = key.toLowerCase();
					
				return _key.indexOf(key);
			}
			else
				return( -1);
		}		
		
		public function get length():int
		{
			return _key.length;
		}
		
		public function count(key:Object):int
		{
			var c:int = 0;
			
			for (var i:int = 0; i < _value.length; i++)
				if (_value[i] == key)
					c++
			
			return c;
		}
		
		public function deleteByObject(obj:*):void
		{
			for (var i:int = 0; i < _value.length; i++)
				if (_value[i] == obj)
				{
					_value[i] = null;
					_key[i] = null;
				}
		}
	}
}