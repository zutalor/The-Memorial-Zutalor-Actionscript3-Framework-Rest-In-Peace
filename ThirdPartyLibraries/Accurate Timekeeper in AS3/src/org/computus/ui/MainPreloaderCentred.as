/*	
	====================================================================================
	2008 | John Dalziel  | The Computus Engine  |  http://www.computus.org

	All source code licenced under The MIT Licence
	====================================================================================  
	
	Preloader
*/

package org.computus.ui
{
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.events.*;

	public class MainPreloaderCentred extends MovieClip
	{

	// -----------------------------------------------------------------------------
	// PROPERTIES

		//var preloader:MovieClip// progress indicator animation

	// -----------------------------------------------------------------------------
	// CONSTRUCTOR & DESTRUCTOR

		public function MainPreloaderCentred():void
		{
			super();
			init();
		}
		
		protected function init():void
		{
			// Stop main timeline
			stop();

			// Track load progress
			this.loaderInfo.addEventListener(ProgressEvent.PROGRESS, onMainLoadProgress);

			// Track Stage size
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.ACTIVATE, onStageResize);
			stage.addEventListener(Event.RESIZE, onStageResize);

			// Centre progress animation on screen
			centreProgressBar();
		}
		
		protected function destroy():void
		{
			// clean up listeners
			this.loaderInfo.removeEventListener(ProgressEvent.PROGRESS, onMainLoadProgress);
			stage.removeEventListener(Event.ACTIVATE, onStageResize);
			stage.removeEventListener(Event.RESIZE, onStageResize);
		}

	// --------------------------------------------------------------
	// EVENTS

		protected function onStageResize(event:Event):void
		{
			centreProgressBar();
		}
		
		protected function onMainLoadProgress(e:ProgressEvent):void
		{
			// update progress animation
			var percent:Number = Math.round((e.bytesLoaded / e.bytesTotal )*100 );
			preloader.gotoAndStop( percent );
			preloader.preloaderText.text = (percent + "%  loaded");

			// check for load complete
			if (e.bytesLoaded == e.bytesTotal )
			{
				onMainLoaded();
			}
		}

		protected function onMainLoaded():void
		{
			// Start main timeline
			destroy();
			play();
		}
		
	// --------------------------------------------------------------
	// POSITION

		protected function centreProgressBar()
		{
			preloader.x = stage.stageWidth / 2;
			preloader.y = stage.stageHeight / 2;
		}
	}
}