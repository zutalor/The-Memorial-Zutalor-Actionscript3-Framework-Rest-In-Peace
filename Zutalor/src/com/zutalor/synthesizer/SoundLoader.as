package com.zutalor.synthesizer 
{
	import com.noteflight.standingwave3.sources.SamplerSource;
	import com.zutalor.utils.gDictionary;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.media.Sound;
	/**
	 * ...
	 * @author Geoff
	 */
	public class SoundLoader 
	{
		protected static const NUM_SAMPLES_TO_LOAD_CONCURRENTLY:int = 2;
	
		protected var numSamples:int;
		protected var numLoaded:int;
		protected var curLoading:int;
		protected var samplerSourcesLoading:int;	
		protected var assetPath:String;
		protected var sounds:gDictionary;
		
		public function loadSounds(pSounds:gDictionary, pAssetPath:String = null, pOnComplete:Function = null):void
		{
			var numSampleMaps:int;
			var props:XML;
			var fileName:String;
			var i:int;
			var curSample:int;
			
			sounds = pSounds;
			assetPath = pAssetPath;
			onComplete = pOnComplete;
			
			numSampleMaps = sampleMaps.length;
			for (i = 0; i < numSampleMaps; i++)
			{
				sampleMap = sampleMaps.getPropsByIndex(i);
				numSamples += sampleMap.samples;
			}
			urls = new Vector.<String>(numSamples);
			samplerSources = new Vector.<SamplerSource>(numSamples);
			
			for (var p:int = 0; p < numSampleMaps; p++)
			{
				sampleMap = sampleMaps.getPropsByIndex(p);
				freqs = new Vector.<Number>;
				
				for (i = 1; i <= sampleMap.samples; i++)
				{
					if (i < 10)
						fileName = sampleMap.filebase + "-0" + i + sampleMap.fileExt;
					else
						fileName = sampleMap.filebase + "-" + i + sampleMap.fileExt;
					
					urls[curSample] = fileName;
					freqs.push(AudioUtils.noteNumberToFrequency((sampleMap.interval * i) + sampleMap.baseMidiNote));
					curSample++;
				}
				frequencies.insert(sampleMap.name, freqs);
				sampleMaps.insert(sampleMap.name, sampleMap);
			}
			loadSamples();
		}
		
// PROTECTED METHODS
		
		protected function loadSamples():void
		{
			if (!urls.length)
				throw new Error("Synth Sounds: cannot load samples.");
			numSamples = urls.length;
			numLoaded = 0;
			for (var i:int = 0; i < NUMSAMPLESTOLOADCONCURRENTLY; i++)
				loadNextSample();
		}
		
		protected function loadNextSample():void
		{
			if (curLoading < numSamples)
			{
				var sound:Sound = new Sound(new URLRequest(assetPath + urls[curLoading]));
				sound.addEventListener(Event.COMPLETE, onSampleLoadComplete, false, 0, true);
				sound.addEventListener(IOErrorEvent.DISK_ERROR, onIOError, false, 0, true);
				sound.addEventListener(IOErrorEvent.IO_ERROR, onIOError, false, 0, true);
				curLoading++;
			}
		}
		
		protected function onIOError(e:Event):void
		{
			trace("IoError");
			throw new Error("IoError");
		}
		
		protected function onSampleLoadComplete(e:Event):void
		{
			var indx:int;
			
			e.target.removeEventListener(Event.COMPLETE, onSampleLoadComplete);
			e.target.removeEventListener(IOErrorEvent.DISK_ERROR, onIOError);
			e.target.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			indx = urls.indexOf(StringUtils.getFileName(e.target.url));
			samplerSources[indx] = new SamplerSource(ad, new SoundGenerator(e.target as Sound, ad));
			numLoaded++;
			if (numLoaded < numSamples)
				loadNextSample();
			else if (onComplete != null)
				onComplete();
		}
		
	}

}