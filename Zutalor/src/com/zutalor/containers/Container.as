package com.zutalor.containers
{
	import com.gskinner.utils.IDisposable;
	import com.zutalor.containers.base.ViewObject;
	import com.zutalor.events.ContainerEvent;
	import com.zutalor.utils.DisplayObjectUtils;
	import com.zutalor.widgets.Focus;
	import flash.display.DisplayObject;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Container extends ViewObject implements IDisposable
	{
		public static const HORIZONTAL:String = "horizontal";
		public static const VERTICAL:String = "vertical";
		public static const KEEP:String = "keep";
		public static const GRID:String = "grid";
		
		public function Container(containerName:String) 
		{
			name = containerName;
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
			//TODO  get rid of listeners
			Focus.hide();
			DisplayObjectUtils.removeAllChildren(this);
		}
		
		public function push(child:DisplayObject, options:Object = null):void
		{
			addChild(child);
			dispatchEvent(new ContainerEvent(ContainerEvent.CONTENT_CHANGED));
		}
		
		public function autoArrangeContainerChildren(options:Object):void
		{
			var i:int = 0;
			var width:int = 0;
			var height:int = 0;
			var padding:Number = 0;
			var arrange:String = HORIZONTAL;
			var child:DisplayObject;
							
			if ("padding" in options)
				padding = options["padding"];
				
			if ("arrange" in options)	
				arrange = options["arrange"];
			
				
			for (i = 0; i < numChildren; i++)
			{
				if (arrange == HORIZONTAL)
				{
					if (padding && padding < 1)
						padding *= width; 
					
					if (i) 
						width += padding;
					
					child = getChildAt(i);
					child.x = width;
					width += child.width;
				}
				else
				{
					if (padding && padding < 1)
						padding *= height; 

					if (i) // no front padding on first entry
						height += padding;
					
					child = getChildAt(i);
					child.y = height;
					height += child.height;
				}
			}
			if (numChildren)
				dispatchEvent(new ContainerEvent(ContainerEvent.CONTENT_CHANGED));
		}
	}
}