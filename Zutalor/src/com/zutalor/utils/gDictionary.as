package com.zutalor.utils
{
	/**
	 * ...
	 * @author Geoff Pepos
	 *
	 */
	public class gDictionary
	{
		public var ignoreCaseInKey:Boolean = true;
		
		private var _keys:Vector.<Object>;
		private var _values:Vector.<Object>;
		private var _initialSize:int;
		private var _fixed:Boolean;
		
		public function gDictionary(initialSize:int = 0, fixed:Boolean=false)
		{
			_initialSize = initialSize;
			_fixed = fixed;
			clear();
		}
		
		private function clear():void
		{
			_keys = new Vector.<Object>(_initialSize, _fixed);
			_values = new Vector.<Object>(_initialSize, _fixed);
			
			//_keys.length = _initialSize;
			//_values.length = _initialSize;
		}
				
		public function dispose():void
		{
			_keys = null;
			_values = null;
		}
		
		public function insert(key:*, obj:*, newkey:*=null):*
		{
			var i:int;
			
			if (!ignoreCaseInKey)
				trace(key);
				
			if (key is String && ignoreCaseInKey)
				key = key.toLowerCase();
			
			i = _keys.indexOf(key);
			
			if (i == -1)
				i = _keys.indexOf(null)
					if (i == -1)
						i = _keys.length;
				
			_values[i] = obj;
			
			if (newkey)
			{
				if (newkey is String && ignoreCaseInKey)
					newkey = newkey.toLowerCase();
				
				_keys[i] = newkey;
			}
			else
				_keys[i] = key;
				
			return obj;
		}

		public function deleteByKey(key:*):void
		{
			var i:int;
			
			if (key is String && ignoreCaseInKey)
				key = key.toLowerCase();
			
			i = _keys.indexOf(key);
			
			if (i != -1)
			{
				_values[i] = null;
				_keys[i] = null;
				_values.splice(i, 1);
				_keys.splice(i, 1);
			}
		}
		
		public function deleteByIndex(index:int):void
		{
			if (index < _keys.length)
			{
				_values[index] = null;
				_keys[index] = null;
				_values.splice(index, 1);
				_keys.splice(index, 1);
			}
		}

		public function getByKey(key:*):*
		{
			var i:int;
			
			if (!key)
				return null;
			else
				if (key is String && ignoreCaseInKey)
					key = key.toLowerCase();
				
				i = _keys.indexOf(key);
				
				if (i != -1)
					return _values[i];
				else
					return null;
		}
		
		public function getByValue(value:*):*
		{
			
			var i:int;
			
			if (!value)
				return null;
			else
				i = _values.indexOf(value);
				
				if (i != -1)
					return _values[i];
				else
					return null;
		}
		
		public function getByIndex(index:int):*
		{
			if (index < _keys.length && index >= 0)
				return _values[index];
			else
				return null;
		}
		
		public function getKeyByIndex(index:int):*
		{
			if (index < _keys.length && index > -1)
				return _keys[index];
			else
				return null;
		}
		
		public function getIndexByKey(key:*):int
		{
			if (key)
			{
				if (key is String && ignoreCaseInKey)
					key = key.toLowerCase();
					
				return _keys.indexOf(key);
			}
			else
				return( -1);
		}
		
		public function get length():int
		{
			return _keys.length;
		}
		
		public function count(key:*):int
		{
			var c:int = 0;
			
			for (var i:int = 0; i < _values.length; i++)
				if (_values[i] == key)
					c++
			
			return c;
		}
		
		
		public function deleteByValue(value:*):void
		{
			var i:int;
			
			i = getByValue(value);
			
			if (i != -1)
			{
				_values[i] = null;
				_keys[i] = null;
				_values.splice(i, 1);
				_keys.splice(i, 1)
			}
		}
	}
}