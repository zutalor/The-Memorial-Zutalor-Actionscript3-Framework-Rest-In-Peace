package {
	
	import be.nascom.components.flash.imageCropper.ImageCropper;
	import be.nascom.components.flash.imageCropper.events.ImageCropperEvent;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;

	[SWF(backgroundColor="0x000000", frameRate="30", width="400", height="400")]
	public class CropperExample extends Sprite
	{
		private var buttonUpload:MovieClip = new MovieClip;
		private var buttonCrop:MovieClip = new MovieClip;
		private var buttonZoomIn:MovieClip = new MovieClip;
		private var buttonZoomOut:MovieClip = new MovieClip;
		
		public function CropperExample()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            
			buttonUpload.graphics.beginFill(0x00ff00);
			buttonUpload.graphics.lineStyle(2, 0xffffff);
			buttonUpload.graphics.drawRect(0,0,100,20);
			buttonUpload.graphics.endFill();
			
			buttonCrop.graphics.beginFill(0xff0000);
			buttonCrop.graphics.lineStyle(2, 0xffffff);
			buttonCrop.graphics.drawRect(0,0,100,20);
			buttonCrop.graphics.endFill();
			
			buttonZoomIn.graphics.beginFill(0x00ff00);
			buttonZoomIn.graphics.lineStyle(2, 0xffffff);
			buttonZoomIn.graphics.drawRect(0,0,100,20);
			buttonZoomIn.graphics.endFill();
			
			buttonZoomOut.graphics.beginFill(0xff0000);
			buttonZoomOut.graphics.lineStyle(2, 0xffffff);
			buttonZoomOut.graphics.drawRect(0,0,100,20);
			buttonZoomOut.graphics.endFill();
			
			var pathGateway:String = "http://frontend.development.nascom.be/amfphp/gateway.php";
			var pathSaveService:String = "SaveJPEG.SaveAsJPEG";
			var pathSaveScript:String;
			var pathUploadScript:String = "http://frontend.development.nascom.be/_scripts/upload.php";
			var pathOrigImg:String = "A.jpg";
			var widthCropper:Number = 50;
			var heightCropper:Number = 50;
			
			var comp:ImageCropper = new ImageCropper(buttonCrop, buttonZoomIn, buttonZoomOut);
			comp.addEventListener(ImageCropperEvent.CROP_COMPLETED, completeHandler);
			comp.addEventListener(ImageCropperEvent.UPLOAD_COMPLETED, uploadHandler);
			comp.addEventListener(ImageCropperEvent.ERROR, errorHandler);
			comp.addEventListener(ImageCropperEvent.BUTTON_STATE_CROP, buttonStateHandler);
			comp.addEventListener(ImageCropperEvent.BUTTON_STATE_UPLOAD, buttonStateHandler);
			comp.addEventListener(ImageCropperEvent.BUTTON_STATE_ZOOM_IN, buttonStateHandler);
			comp.addEventListener(ImageCropperEvent.BUTTON_STATE_ZOOM_OUT, buttonStateHandler);
			
//			comp.setUpload(buttonUpload,pathUploadScript);
			comp.setSourceImage(pathOrigImg);
//	  		comp.initClassic(pathSaveScript);
	  		comp.initAMF(pathGateway, pathSaveService);
	  		
			addChild(comp);
			//addChild(buttonUpload);
			addChild(buttonCrop);
			addChild(buttonZoomIn);
			addChild(buttonZoomOut);
			
			buttonCrop.x = buttonUpload.x+10+buttonUpload.width;
			buttonZoomIn.y = 20;
			buttonZoomIn.x = buttonZoomIn.x+10+buttonZoomIn.width;
			buttonZoomOut.y = buttonZoomIn.y; 
		}
		
		private function buttonStateHandler(event:ImageCropperEvent):void
		{
			if(event.type == ImageCropperEvent.BUTTON_STATE_CROP){
				buttonCrop.enabled = event.enabled;
				buttonCrop.visible = event.enabled;
			}else if (event.type == ImageCropperEvent.BUTTON_STATE_UPLOAD){
				buttonUpload.enabled = event.enabled;
				buttonUpload.visible = event.enabled;
			}else if (event.type == ImageCropperEvent.BUTTON_STATE_ZOOM_IN){
				buttonZoomIn.enabled = event.enabled;
				buttonZoomIn.visible = event.enabled;
			}else if (event.type == ImageCropperEvent.BUTTON_STATE_ZOOM_OUT){
				buttonZoomOut.visible = event.enabled;
				buttonZoomOut.visible = event.enabled;
			}
		}
		
		private function completeHandler(event:ImageCropperEvent):void
		{
			trace("cropping is succesfull: "+event.pathCroppedImage);
		}
		
		private function uploadHandler(event:ImageCropperEvent):void
		{
			trace("upload is succesfull");
		}
		
		private function errorHandler(event:ImageCropperEvent):void
		{
			trace("Error: "+event.error);
		}
	}
}
