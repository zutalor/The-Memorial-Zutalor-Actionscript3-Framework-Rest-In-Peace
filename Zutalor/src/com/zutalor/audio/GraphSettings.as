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
		public var mute:Boolean;
		public var plotter:Plotter;
		public var preset:SynthPreset;
		public var lineStyle:int = 3;
		public var color:uint = 0;
		public var dotsize:int = 0;
		public var noteScaling:Number;
		public var soundName:String;
		public var graph:int;
		public var pan:Number;		
		public var speed:Number;
		public var range:Number;
		public var noteOverlap:Number;
	}
}