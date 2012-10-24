package com.zutalor.propertyManagers 
{
	import com.zutalor.utils.Singleton;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class SequencePropsManager extends NestedPropsManager
	{
		protected static var _sequencePropsManager:SequencePropsManager;

		public function SequencePropsManager()
		{
			Singleton.assertSingle(SequencePropsManager);
		}
		
		public static function gi():SequencePropsManager
		{
			if (!_sequencePropsManager)
				_sequencePropsManager = new SequencePropsManager();

			return _sequencePropsManager;
		}
		
	}
}