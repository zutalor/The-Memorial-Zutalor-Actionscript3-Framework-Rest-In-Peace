package com.zutalor.synthesizer 
{
	import com.noteflight.standingwave3.elements.AudioDescriptor;
	import com.noteflight.standingwave3.generators.SoundGenerator;
	import com.noteflight.standingwave3.sources.SamplerSource;
	import com.noteflight.standingwave3.utils.AudioUtils;
	import com.zutalor.properties.PropertyManager;
	import com.zutalor.synthesizer.properties.SampleMap;
	import com.zutalor.text.StringUtils;
	import com.zutalor.utils.gDictionary;
	import com.zutalor.utils.ShowError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.media.Sound;
	import flash.net.URLRequest;
	/**
	 * ...
	 * @author Geoff
	 */
	public class SoundLoader 
	{
		protected var samplesToLoadConcurrently:int = 2;
		protected var numSampleMaps:int;
		protected var curSampleMap:int;
		protected var numSamples:int;
		protected var numLoaded:int;
		protected var curLoading:int;
		
		protected var assetPath:String;
		protected var sampleMaps:PropertyManager;
		protected var sampleMap:SampleMap;
		protected var ad:AudioDescriptor;
		protected var onComplete:Function;
		
		public function SoundLoader() { }
		
		public function load(pSampleMaps:PropertyManager, pAssetPath:String, 
											pAd:AudioDescriptor, pOnComplete:Function = null):void
		{
			var fileName:String;
			
			sampleMaps = pSampleMaps;
			assetPath = pAssetPath;
			ad = pAd;
			onComplete = pOnComplete;

			curSampleMap = 0;			
			numSampleMaps = sampleMaps.length;
			
			for (var p:int = 0; p < numSampleMaps; p++)
			{
				sampleMap = sampleMaps.getPropsByIndex(p);
				numSamples = sampleMap.samples;
				sampleMap.urls = new Vector.<String>(numSamples);
				sampleMap.samplerSources = new Vector.<SamplerSource>(numSamples);	
				sampleMap.frequencies = new Vector.<Number>(numSamples);
				
				for (var i:int = 0; i < sampleMap.samples; i++)
				{
					if (i < 9)
						fileName = sampleMap.filebase + "-0" + (i+1) + sampleMap.fileExt;
					else
						fileName = sampleMap.filebase + "-" + (i + 1) + sampleMap.fileExt;
					
					sampleMap.urls[i] = fileName;
					sampleMap.frequencies[i] = (AudioUtils.noteNumberToFrequency((sampleMap.interval * i)
																					+ sampleMap.baseMidiNote));
				}
			}
			loadSamples();
		}
		
// PROTECTED METHODS
		
		protected function loadSamples():void
		{
			if (curSampleMap < numSampleMaps)
			{
				numLoaded = curLoading = 0;
				sampleMap = sampleMaps.getPropsByIndex(curSampleMap);
				if (!sampleMap)
					ShowError.fail(SoundLoader, "No sample maps.");
				
				numSamples = sampleMap.urls.length;
				for (var i:int = 0; i < samplesToLoadConcurrently; i++)
					loadNextSample();
			}
			else if (onComplete != null)
				onComplete();
		}
		
		protected function loadNextSample():void
		{
			if (curLoading < numSamples)
			{
				var sound:Sound = new Sound(new URLRequest(assetPath + sampleMap.urls[curLoading]));
				sound.addEventListener(Event.COMPLETE, onSampleLoadComplete, false, 0, true);
				sound.addEventListener(IOErrorEvent.DISK_ERROR, onIOError, false, 0, true);
				sound.addEventListener(IOErrorEvent.IO_ERROR, onIOError, false, 0, true);
				curLoading++;
			}
		}
		
		protected function onSampleLoadComplete(e:Event):void
		{
			var indx:int;
			
			e.target.removeEventListener(Event.COMPLETE, onSampleLoadComplete);
			e.target.removeEventListener(IOErrorEvent.DISK_ERROR, onIOError);
			e.target.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			
			indx = sampleMap.urls.indexOf(StringUtils.getFileName(e.target.url));
			sampleMap.samplerSources[indx] = new SamplerSource(ad, new SoundGenerator(e.target as Sound, ad));
			numLoaded++;
			if (numLoaded < numSamples)
				loadNextSample();
			else 
			{
				curSampleMap++;
				loadSamples();
			}
		}
		
		protected function onIOError(e:Event):void
		{
			trace("IoError");
			throw new Error("IoError");
		}	
	}
}