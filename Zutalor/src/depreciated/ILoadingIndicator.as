package depreciated 
{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import net.guttershark.support.preloading.events.PreloadProgressEvent;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public interface ILoadingIndicator
	{
		function init(stageRef:Stage, backgroundColor:uint, trackColor:uint, indicatorColor:uint):void
		function reset(delay:Number=0):void
		function onLoadingProgress(ppe:PreloadProgressEvent):void
		function initImages(forground:DisplayObject, background:DisplayObject, horizontal:Boolean = true):void
		function setPercent(percent:Number, status:String = ""):void
	}
}