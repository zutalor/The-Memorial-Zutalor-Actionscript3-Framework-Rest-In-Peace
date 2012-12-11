package com.zutalor.containers
{
	import com.gskinner.utils.IDisposable;
	import com.zutalor.containers.base.ContainerObject;
	import com.zutalor.containers.utils.Arranger;
	import com.zutalor.containers.utils.ObjectRemover;
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
		private var _arranger:Arranger;
		
		public function Container(containerName:String = null) 
		{
			if (containerName)
				name = containerName;
				
			_arranger = new Arranger(this);
		}
		
		public function autoArrangeChildren(options:Object):void
		{
			var i:int = 0;
			var width:int = 0;
			var height:int = 0;
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
				contentChanged();
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