package com.zutalor.utils 
{
	import com.adobe.images.PNGEncoder;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author G
	 */
	public class CaptureScreen 
	{
		
		public function CaptureScreen()
		{
			
		}
		
		public static function stage(fileName:String):void
		{			
			var bitmapData:BitmapData;
		
			bitmapData = new BitmapData(StageRef.stage.stageWidth,StageRef.stage.stageHeight);
			bitmapData.draw(StageRef.stage,new Matrix());
			var bitmap : Bitmap = new Bitmap(bitmapData);
			
			var ba:ByteArray =  PNGEncoder.encode(bitmapData);
			
			var newImage:File = File.desktopDirectory.resolvePath(fileName + ".png");
			var fileStream:FileStream = new FileStream();
			fileStream.open(newImage, FileMode.UPDATE);
			fileStream.writeBytes(ba);
		}
	}
}