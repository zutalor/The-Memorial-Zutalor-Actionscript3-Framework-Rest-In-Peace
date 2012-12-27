package com.zutalor.synthesizer 
{
	import com.zutalor.loaders.URLLoaderG;
	import com.zutalor.properties.PropertyManager;
	import com.zutalor.synthesizer.properties.SampleMap;
	import com.zutalor.synthesizer.properties.SynthPreset;
	/**
	 * ...
	 * @author Geoff
	 */
	public class PresetLoader 
	{
		public var presets:PropertyManager;
		public var sampleMaps:PropertyManager;
		
		public function PresetLoader():void
		{
			presets = new PropertyManager(SynthPreset);
			sampleMaps = new PropertyManager(SampleMap);
		}
		
		public function load(xmlUrl:String, onComplete:Function):void
		{
			var loader:URLLoaderG = new URLLoaderG();
			
			loader.load(xmlUrl, onXMLLoadComplete);
		
			function onXMLLoadComplete(lg:URLLoaderG):void
			{
				//TODO Handle error.
				presets.parseXML(XML(lg.data).presets);
				sampleMaps.parseXML(XML(lg.data).sampleMaps);
			}
					
			function finishSetup():void
			{
				if (onComplete != null)
					onComplete();
			}
		}
		
	}

}