package com.zutalor.containers
{
	import adobe.utils.CustomActions;
	import com.gskinner.utils.IDisposable;
	import com.zutalor.components.Component;
	import com.zutalor.events.ContainerEvent;
	import com.zutalor.properties.ApplicationProperties;
	import com.zutalor.propertyManagers.Presets;
	import com.zutalor.ui.Focus;
	import com.zutalor.utils.DisplayObjectUtils;
	import com.zutalor.utils.ShowError;
	import com.zutalor.view.controller.ViewController;
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
		
		private var _containerName:String;	
		private var _originalWidth:Number;
		private var _originalHeight:Number;
		private var _width:Number;
		private var _height:Number;
				
		public function Container(containerName:String, width:Number=0, height:Number=0) 
		{
			_containerName = this.name = containerName;
			init(width, height);
		}
		
		private function init(width:Number = 0, height:Number = 0):void
		{
			this.width = _originalWidth = width;
			this.height = _originalHeight = height;
			cacheAsBitmap = true;
		}
		
		public function get originalWidth():Number
		{
			return _originalWidth;
		}
		
		public function get originalHeight():Number
		{
			return _originalHeight;
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
		
		override public function set width(n:Number):void
		{
			super.width = _width = n;
		}
		
		override public function get width():Number
		{
			return _width;
		}
		
		override public function get height():Number
		{
			return _height;				
		}		

		override public function set height(n:Number):void
		{
			super.height = _height = n;
		}
		
		public function get containerName():String
		{
			return _containerName;
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