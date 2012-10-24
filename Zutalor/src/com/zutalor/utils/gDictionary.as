package com.zutalor.utils 
{
	/**
	 * ...
	 * @author Geoff Pepos
	 * okay we could use objects or a dictionary, yet this works.
	 */
	public class gDictionary
	{
		private var _key:Array;
		private var _gDictionary:Array;
		
		public function gDictionary() 
		{
			_key = [];
			_gDictionary = [];
		}
		
		public function clear():void
		{
			_key = [];
			_gDictionary = [];
		}
		
		public function dispose():void
		{
			_key = null;
			_gDictionary = null;
		}
		
		public function addOrReplace(name:String, obj:*, newName:String=null):void
		{
			var i:int;
			
			name = name.toLowerCase();
			
			i = _key.indexOf(name);
			
			if (i == -1)
				i = _key.indexOf(null)
					if (i == -1)
						i = _key.length;
				
			_gDictionary[i] = obj;
			
			if (newName)
				_key[i] = newName.toLowerCase();
			else
				_key[i] = name;
		}

		public function deleteByName(name:String):void
		{
			var i:int;
			
			name = name.toLowerCase();
			
			i = _key.indexOf(name);
			
			if (i != -1)
			{
				_gDictionary[i] = null;
				_key[i] = null;
				_gDictionary.splice(i, 1);
				_key.splice(i, 1);
			}
		}
		
		public function deleteByIndex(index:int):void
		{			
			if (index < _key.length)
			{
				_gDictionary[index] = null;
				_key[index] = null;
				_gDictionary.splice(index, 1);
				_key.splice(index, 1);
			}
		}

		public function getByName(name:String):*
		{
			var i:int;
			
			if (!name)
				return null;
			else	
				name = name.toLowerCase();			
				
				i = _key.indexOf(name);
				
				if (i != -1)
					return _gDictionary[i];
				else
					return null;
		}
		
		public function getByIndex(index:int):*
		{
			if (index < _key.length && index >= 0)
				return _gDictionary[index];
			else
				return null;
		}
		
		public function getKeyByIndex(index:int):String
		{
			if (index < _key.length && index > -1)
				return _key[index];
			else
				return null;
		}
		
		public function getIndexByName(name:String):int
		{
			if (name)
				return _key.indexOf(name.toLowerCase());
			else
				return( -1);
		}		
		
		public function get length():int
		{
			return _key.length;
		}
		
		public function count(name:String):int
		{
			var c:int = 0;
			
			for (var i:int = 0; i < _gDictionary.length; i++)
				if (_gDictionary[i] == name)
					c++
			
			return c;
		}
		
		public function deleteByObject(obj:*):void
		{
			for (var i:int = 0; i < _gDictionary.length; i++)
				if (_gDictionary[i] == obj)
				{
					_gDictionary[i] = null;
					_key[i] = null;
				}
		}
	}
}