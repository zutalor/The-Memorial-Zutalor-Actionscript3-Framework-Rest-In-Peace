package com.zutalor.synthesizer
{
	import com.zutalor.text.StringUtils;
	import com.zutalor.text.StringUtils;
	import com.zutalor.utils.gDictionary;
	import com.zutalor.text.StringUtils;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class SynthPresets
	{
		private var _presets:gDictionary;
		
		
		public function SynthPresets() 
		{
			_init();
		}
		
		private function _init():void
		{
			_presets = new gDictionary();
		}
		
		public function getPresetByName(presetName:String):SynthPreset
		{
			return _presets.getByKey(presetName);
		}
		
		public function addPreset(presetName:String, preset:SynthPreset):void
		{
			_presets.insert(presetName, preset);
		}
		
		public function parseXml(xml:XML):void
		{
			var preset:SynthPreset;
			var props:XMLList;
			var n:int;

			n = xml.presets.preset.length();
			
			for (var i:int = 0; i < n; i++)
			{
				preset = new SynthPreset();
				props = xml.presets.preset[i].props;
				
				preset.name = xml.presets.preset[i].@name;
				preset.soundName = props.@soundName;
				preset.midiNoteNumbers = StringUtils.toBoolean(props.@midiNoteNumbers);
				preset.rounding = StringUtils.toBoolean(props.@rounding);
				preset.lowNote = props.@lowNote;
				preset.highNote = props.@highNote;
				preset.noteTiming = props.@noteTiming;
				preset.pan = props.@pan;
				preset.gain = props.@gain;
				preset.attack = props.@attack;
				preset.decay = props.@decay;
				preset.hold = props.@hold;
				preset.sustain = props.@sustain;
				preset.release = props.@release;
				preset.metadata = props.@metadata;
				preset.humanize = StringUtils.toBoolean(props.@humanize);
				preset.pvUp = props.@pvUp;
				preset.pvDown = props.@pvDown;
				preset.pvProbability = props.@pvProbablility;
				preset.pvIterations = props.@pvIterations;
				preset.pvFalloff = props.@pvFalloff;
				preset.tvUp = props.@tvUp;
				preset.tvDown = props.@tvDown;
				preset.tvProbability = props.@tvProbablility;
				preset.tvIterations = props.@tvIterations;
				preset.tvFalloff = props.@tvFalloff;
				
				_presets.insert(preset.name, preset);
			}
		}					
	}
}