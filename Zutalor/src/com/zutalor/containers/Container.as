package com.zutalor.containers
{
	import com.gskinner.utils.IDisposable;
	import com.zutalor.containers.base.ContainerObject;
	import com.zutalor.containers.utils.ObjectRemover;
	import com.zutalor.utils.Scale;
	import com.zutalor.utils.StageRef;
	import com.zutalor.view.controller.ViewController;
	import com.zutalor.widgets.Focus;
	import flash.display.DisplayObject;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Container extends ContainerObject implements IDisposable
	{	
		public const HORIZONTAL:String = "horizontal";
		public const VERTICAL:String = "vertical";
		
		public var viewController:ViewController;
				
		public function Container(containerName:String)
		{
			if (containerName)
				name = containerName;
		}
		
		public function autoArrangeChildren(options:Object):void
		{
			var i:int = 0;
			var w:Number = 0;
			var h:Number = 0;
			var padding:Number = 0;
			var orientation:String = HORIZONTAL;
			var child:DisplayObject;
							
			if ("padding" in options)
				padding = options["padding"];
				
			if ("orientation" in options)
				orientation = options["orientation"];
				
			for (i = 0; i < numChildren; i++)
			{
				if (orientation == HORIZONTAL)
				{
					if (padding && padding < 1)
						padding *= w;
					
					if (i)
						w += padding;
					
					child = getChildAt(i);
					child.x = w;
					w += child.width;
				}
				else
				{
					if (padding && padding < 1)
						padding *= h;

					if (i) // no front padding on first entry
						h += padding;
					
					child = getChildAt(i);
					child.y = h;
					h += child.height;
				}
			}
			if (numChildren)
				contentChanged();
		}
		
		public function callContainerMethod(method:String, params:String):void
		{
			this[method](params);
			//TODO check for errors
		}
		
		public function callContainerChildMethod(itemName:String, method:String, params:String):void
		{
			var item:*;
			//TODO check errors
			item = this[item];
			item[method](params);
		}
		
		override public function recycle():void
		{
			// todo
			dispose();
		}
			
		override public function dispose():void
		{
			var objectRemover:ObjectRemover = new ObjectRemover();
			
			super.dispose();
			objectRemover.removeAllChildren(this);
			Focus.hide();
		}
		
		public function push(child:ContainerObject, options:Object = null):void
		{
			addChild(child);
			contentChanged();
		}
		
		public function contentChanged():void
		{
			
		}
	}
}