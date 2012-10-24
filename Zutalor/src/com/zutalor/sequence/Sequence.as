package com.zutalor.sequence 
{
	import com.zutalor.propertyManagers.NestedPropsManager;
	import com.zutalor.propertyManagers.Props;
	import com.zutalor.properties.SequenceItemProperties;
	import com.zutalor.properties.SequenceProperties;
	import com.zutalor.utils.MasterClock;
	import flash.events.Event;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Sequence
	{
		private var currentSequence:String;
		private var sequenceIndx:int;
		private var sm:NestedPropsManager;
		private var _controller:Function;
		private var _onComplete:Function;
		private var _caller:*
		
		public function Sequence() 
		{
			sm = Props.sequences;		
		}
		
		public function play(sequenceName:String, caller:*, controller:Function, onComplete:Function):void
		{
			var sp:SequenceProperties;

			_caller = caller;
			_controller = controller;
			_onComplete = onComplete;
			
			sp = sm.getPropsById(sequenceName);
			
			if (sp)
			{
				currentSequence = sequenceName;
				sequenceIndx = 0;
				_caller.addEventListener(Event.COMPLETE, prepSequenceItem, false, 0, true);
				prepSequenceItem();
			}
		}
		
		private function prepSequenceItem(e:Event = null):void
		{
			var sip:SequenceItemProperties;
			
			if (sequenceIndx < sm.getNumItems(currentSequence))
			{
				sip = sm.getItemPropsByIndex(currentSequence, sequenceIndx);
				MasterClock.callOnce(nextSequenceItem, sip.delay);
			}
			else
			{
				_caller.removeEventListener(Event.COMPLETE, prepSequenceItem);
				_onComplete();
			}
		}
		
		private function nextSequenceItem():void
		{
			var sip:SequenceItemProperties;
			sip = sm.getItemPropsByIndex(currentSequence, sequenceIndx);
			if (sip)
			{
				sequenceIndx++
				_controller(sip.menuItem);
			}
		}			
	}
}