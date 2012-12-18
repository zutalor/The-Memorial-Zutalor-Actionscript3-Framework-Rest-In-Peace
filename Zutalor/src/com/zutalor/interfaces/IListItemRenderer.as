package com.zutalor.interfaces 
{
	import com.zutalor.components.list.ListProperties;
	import com.zutalor.containers.Container;
	
	/**
	 * ...
	 * @author Geoff
	 */
	public interface IListItemRenderer 
	{
		function render(lp:ListProperties, c:Container):void
	}
	
}