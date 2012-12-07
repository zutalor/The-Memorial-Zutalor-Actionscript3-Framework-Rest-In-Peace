package com.zutalor.containers
{
	import com.gskinner.utils.IDisposable;
	import com.zutalor.containers.base.ViewObject;
	import com.zutalor.containers.utils.Arranger;
	import com.zutalor.containers.utils.ObjectRemover;
	import com.zutalor.events.ContainerEvent;
	import com.zutalor.widgets.Focus;
	import flash.display.DisplayObject;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Container extends ViewObject implements IDisposable
	{	
		private var _arranger:Arranger;
		
		public function Container(containerName:String) 
		{
			name = containerName;
			_arranger = new Arranger(this);
		}
		
		public function get arranger():Arranger
		{
			return _arranger;
		}
		
		public function callContainerMethod(method:String, params:String):void
		{
			this[method](params);
		}
		
		override public function recycle():void
		{
			// todo
			dispose();
		}
			
		override public function dispose():void
		{
			var objectRemover:ObjectRemover = new ObjectRemover();
			objectRemover.removeAllChildren(this);
			Focus.hide();
		}
		
		public function push(child:DisplayObject, options:Object = null):void
		{
			addChild(child);
			dispatchEvent(new ContainerEvent(ContainerEvent.CONTENT_CHANGED));
		}
	}
}