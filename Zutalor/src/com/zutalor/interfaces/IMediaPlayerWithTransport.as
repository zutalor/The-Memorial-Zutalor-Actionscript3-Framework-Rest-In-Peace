package com.zutalor.interfaces 
{
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public interface IMediaPlayerWithTransport extends IMediaPlayer
	{
		function initTransport(transportViewId:String, transportContainer:String):void
	}
	
}