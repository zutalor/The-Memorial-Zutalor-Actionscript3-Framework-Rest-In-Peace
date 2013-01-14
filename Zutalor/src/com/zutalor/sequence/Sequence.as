package com.zutalor.sequence 
{
	import com.zutalor.application.AppController;
	import com.zutalor.events.UIEvent;
	import com.zutalor.properties.NestedPropsManager;
	import com.zutalor.utils.MasterClock;
	import com.zutalor.utils.StageRef;
	import flash.events.Event;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Sequence
	{
		private var currentSequence:String;
		private var sequenceIndx:int;
		private var _controller:AppController;
		private var _onComplete:Function;
		
		private static var _presets:NestedPropsManager;
		
		public function Sequence() {}
				
		public static function registerPresets(options:Object):void
		{
			if (!_presets)
				_presets = new NestedPropsManager();
			
			_presets.parseXML(SequenceProperties, SequenceItemProperties, options.xml[options.nodeId], options.childNodeId, 
																							options.xml[options.childNodeId]);
		}
		
		public function play(sequenceName:String, controller:AppController, onComplete:Function):void
		{
			var sp:SequenceProperties;

			_controller = controller;
			_onComplete = onComplete;
			
			sp = _presets.getPropsById(sequenceName);
			
			if (sp)
			{
				currentSequence = sequenceName;
				sequenceIndx = 0;
				_controller.addEventListener(Event.COMPLETE, prepSequenceItem, false, 0, true);
				prepSequenceItem();
			}
		}
		
		private function prepSequenceItem(e:Event = null):void
		{
			var sip:SequenceItemProperties;
			
			if (sequenceIndx < _presets.getNumItems(currentSequence))
			{
				sip = _presets.getItemPropsByIndex(currentSequence, sequenceIndx);
				MasterClock.callOnce(nextSequenceItem, sip.delay);
			}
			else
			{
				_controller.removeEventListener(Event.COMPLETE, prepSequenceItem);
				_onComplete();
			}
		}
		
		private function nextSequenceItem():void
		{
			var sip:SequenceItemProperties;
			sip = _presets.getItemPropsByIndex(currentSequence, sequenceIndx);
			if (sip)
			{
				sequenceIndx++;
				StageRef.stage.dispatchEvent(new UIEvent(UIEvent.APP_STATE_SELECTED, null, sip.item));
			}
		}			
	}
}