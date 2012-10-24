package com.zutalor.utils
{
	import com.zutalor.utils.MeasureVideoFrameRate;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Measure  
	{
		public static function frameRate(testFileLowUrl:String, testFileMedUrl:String, testFileHighUrl:String, curBandwidth:String, onComplete:Function):void
		{
			_measureVideoFrameRate = new MeasureVideoFrameRate();
			_measureVideoFrameRate.start(testFileUrl, testFileMedUrl, testFileHightUrl, curBandwidth, measureFinished);
			
			function measureFinished():void
			{
				ap.videoPlaybackFPS = _measureVideoFrameRate.averageFrameRate;
				_measureVideoFrameRate.dispose();

				if (onComplete != null)
					onComplete();
			}
		}
	}
}