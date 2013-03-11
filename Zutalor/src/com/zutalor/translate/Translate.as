package com.zutalor.translate
{
	import com.zutalor.properties.PropertyManager;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Translate
	{
		protected static var _presets:PropertyManager;
		protected static var _tp:TranslationProperties;
		
		public static function registerPresets(options:Object):void
		{
			if (!_presets)
				_presets = new PropertyManager(TranslationProperties);
			
			_presets.parseXML(options.xml[options.nodeId]);
		}
		
		public static function get presets():PropertyManager
		{
			return _presets;
		}
		
		public static function getNumItems(id:String):int
		{
			return _presets.length;
		}
		
		public static function text(item:String):String
		{
			var text:String = "";

			if (item)
			{
				_tp = _presets.getPropsByName(item);
				if (_tp)
				{
					if (_tp.tText)
						text = _tp.tText;
				}
				else
					text = item;
			}
			return text;
		}
		
		public static function getSoundName(item:String):String
		{
			_tp = _presets.getPropsByName(item);
			if (_tp)
				return _tp.sound;
			else
				return "";
		}
		
		public static function getMetaByName(name:String):String
		{
			_tp = _presets.getPropsByName(name);
			if (_tp)
				if (_tp.tMeta)
					return _tp.tMeta;
				else
					return "";
			else
				return "";
		}
		
		public static function getMetaByIndex(index:int):String
		{
			_tp = _presets.getPropsByIndex(index);
			if (_tp)
				return getMetaByName(_tp.name);
			else
				return "";
		}
	}
}