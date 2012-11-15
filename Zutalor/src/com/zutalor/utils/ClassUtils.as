package com.zutalor.utils 
{
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ClassUtils 
	{
		
		public static function getClass(obj:Object):Class 
		{
			return Class(getDefinitionByName(getQualifiedClassName(obj)));
		}
	}
}