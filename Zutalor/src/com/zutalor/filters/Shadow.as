package com.zutalor.filters
{
	import com.zutalor.filters.base.FuzzyFilter;
	import com.zutalor.filters.base.FuzzyFilterProperties;
	import com.zutalor.properties.PropertyManager;
	import flash.filters.DropShadowFilter;
	
	/**
	 * ...
	 * @author Geoff
	 */
	public class Shadow extends FuzzyFilter
	{
		override protected function reflect():Class
		{
			return DropShadowFilter;
		}
	}
}