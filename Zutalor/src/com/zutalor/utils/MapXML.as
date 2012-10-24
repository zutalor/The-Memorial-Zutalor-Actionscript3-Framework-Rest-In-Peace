package com.zutalor.utils  
{
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class MapXML
	{
		
		public static function attributeToClass(xml:XML, Klass:*):void 
		{
			var e:Enumerator = Enumerator.create(Klass);
			var key:Object;
			while( key = e.next() )
			{
				if (Klass[key] is Boolean)
				{
					if (!Klass[key]) // default wasn't set to true in constructor
						if (String(xml.attribute(key)) == "true")
							Klass[key] = true;	
						else if (String(xml.attribute(key)) == "false")	
							Klass[key] = false;	
				}
				else if (String(xml.attribute(key)) != "")
				{
					if (!Klass[key]) // default wasn't set in contructor
						Klass[key] = xml.attribute(key);		
				}
			}
			xml = null;
			e.dispose();
			e = null;
			key = null;
		}		
	}
}