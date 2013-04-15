package com.zutalor.audio
{
	import com.zutalor.synthesizer.properties.SynthPreset;
	import com.zutalor.widgets.Plotter;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class GraphSettings
	{
		public var plotter:Plotter;
		public var preset:SynthPreset;
		public var noteScaling:Number;
		public var lineStyle:int = 3;
		public var color:uint = 0;
		public var dotsize:int = 0;
		public var samples:int;
		public var graph:int;
		public var speed:Number;
		public var range:Number;
		public var reverse:Boolean;
		public var variableTiming:Boolean;
		public var noteType:String;
		public var sound:String;
		public var totalTime:int;
		
		public function GraphSettings() { }
	}
}