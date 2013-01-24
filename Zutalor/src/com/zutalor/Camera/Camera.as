package com.zutalor.Camera
{
    import events.CameraEvent;

    import flash.display.BitmapData;
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.MediaEvent;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.media.CameraRoll;
    import flash.media.CameraUI;
    import flash.media.MediaPromise;
    import flash.media.MediaType;
    import flash.utils.ByteArray;

   import mx.events.DynamicEvent;
    import mx.graphics.codec.JPEGEncoder;

    [Event(name = "fileReady", type = "events.CameraEvent")]
    public class Camera extends EventDispatcher
    {
        protected var camera:CameraUI;
        protected var loader:Loader;
        public var file:File;

        public function CameraUtil()
        {
            if (CameraUI.isSupported)
            {
                camera = new CameraUI();
                camera.addEventListener(MediaEvent.COMPLETE, mediaEventComplete);
            }
        }

        public function takePicture():void
        {
            if (camera)
                camera.launch(MediaType.IMAGE);
        }

        protected function mediaEventComplete(event:MediaEvent):void
        {
            var mediaPromise:MediaPromise = event.data;
            if (mediaPromise.file == null)
            {
                // For iOS we need to load with a Loader first
                loader = new Loader();
                loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderCompleted);
                loader.loadFilePromise(mediaPromise);
                return;
            }
            else
            {
                // Android we can just dispatch the event that it's complete
                file = new File(mediaPromise.file.url);
                dispatchEvent(new CameraEvent(CameraEvent.FILE_READY, file));
            }
        }

        protected function loaderCompleted(event:Event):void
        {
            var loaderInfo:LoaderInfo = event.target as LoaderInfo;
            if (CameraRoll.supportsAddBitmapData)
            {
                var bitmapData:BitmapData = new BitmapData(loaderInfo.width, loaderInfo.height);
                bitmapData.draw(loaderInfo.loader);
                file = File.applicationStorageDirectory.resolvePath("receipt" + new Date().time + ".jpg");
                var stream:FileStream = new FileStream()
                stream.open(file, FileMode.WRITE);
                var j:JPEGEncoder = new JPEGEncoder();
                var bytes:ByteArray = j.encode(bitmapData);
                stream.writeBytes(bytes, 0, bytes.bytesAvailable);
                stream.close();
                trace(file.url);
                dispatchEvent(new CameraEvent(CameraEvent.FILE_READY, file));
            }
        }

    }
}