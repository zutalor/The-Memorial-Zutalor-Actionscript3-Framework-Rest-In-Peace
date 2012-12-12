package com.zutalor.interfaces 
{
	import com.zutalor.components.list.ListProperties;
	import com.zutalor.containers.ScrollingContainer;
	
	/**
	 * ...
	 * @author Geoff
	 */
	public interface IListItemRenderer 
	{
		function render(lp:ListProperties, sc:ScrollingContainer):void
	}
	
}