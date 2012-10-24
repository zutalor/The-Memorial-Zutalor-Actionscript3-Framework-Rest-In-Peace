package com.zutalor.preloading.workers
{
	import flash.utils.Dictionary;
	
	import com.zutalor.preloading.workers.BitmapWorker;
	import com.zutalor.preloading.workers.SWFWorker;
	import com.zutalor.preloading.workers.SoundWorker;
	import com.zutalor.preloading.workers.Worker;
	import com.zutalor.preloading.workers.XMLWorker;

	/**
	 * The WorkerInstances class is an instance factory that returns instances
	 * of workers based on a filetype being loaded.
	 * 
	 * <p>This is used internally in an Asset. If you are adding any other types
	 * of assets to be preloaded</p>
	 * 
	 * <p>Default workers: bmp,jpg,jpeg,png,gif,swf,mp3,zip,xml,flv</p>
	 * 
	 * <script src="http://mint.codeendeavor.com/?js" type="text/javascript"></script>
	 */
	final public class WorkerInstances
	{
		
		/**
		 * Stores class references to workers.
		 */
		private static var workerKlasses:Dictionary;
		
		/**
		 * Flag indicating if the defaults have been registered already.
		 */
		private static var defaultsRegistered:Boolean;
		
		/**
		 * @private
		 * 
		 * Registers the default worker instances internally. The default types are:
		 * 
		 * <ul>
		 * <li>jpg</li>
		 * <li>jpeg</li>
		 * <li>png</li>
		 * <li>gif</li>
		 * <li>bmp</li>
		 * <li>mp3</li>
		 * <li>xml</li>
		 * <li>zip</li>
		 * <li>swf</li>
		 * <li>flv</li>
		 * </ul>
		 */
		public static function RegisterDefaultWorkers():void
		{
			if(defaultsRegistered) return;
			if(!workerKlasses) workerKlasses = new Dictionary(true);
			RegisterWorkerForFileType("jpg",BitmapWorker);
			RegisterWorkerForFileType("jpeg",BitmapWorker);
			RegisterWorkerForFileType("png",BitmapWorker);
			RegisterWorkerForFileType("gif",BitmapWorker);
			RegisterWorkerForFileType("bmp",BitmapWorker);
			RegisterWorkerForFileType("png",BitmapWorker);
			RegisterWorkerForFileType("swf",SWFWorker);
			RegisterWorkerForFileType("xml",XMLWorker);
			RegisterWorkerForFileType("flv",FLVWorker);
			RegisterWorkerForFileType("f4v",FLVWorker);
			RegisterWorkerForFileType("mp3",SoundWorker);
			RegisterWorkerForFileType("aif",SoundWorker);
			RegisterWorkerForFileType("css",StyleSheetWorker);
			defaultsRegistered = true;
		}

		/**
		 * Registers a worker for a file type. The file type string should be a file extension 
		 * less the period. EX: "jpg","jpeg", etc.
		 * 
		 * @param fileType The file type to register the worker too
		 * @param workerKlass The worker class to use for the specified file type. This must be a class reference.
		 */
		public static function RegisterWorkerForFileType(fileType:String, workerKlass:Class):void
		{			
			workerKlasses[fileType] = workerKlass;
		}
		
		/**
		 * Get an instance of the worker specified by type.
		 * 
		 * @param fileType The type of the worker. EX: 'bitmap', or 'swf', etc. The Worker must
		 * have been registered previously before getting an instnace of it.
		 */
		public static function GetWorkerInstance(fileType:String):Worker
		{
			if(!workerKlasses[fileType]) throw new Error("No worker for filetype " + fileType + " was registered.");
			var klass:Class = workerKlasses[fileType];
			var worker:Worker = new klass();
			return worker;
		}
	}
}