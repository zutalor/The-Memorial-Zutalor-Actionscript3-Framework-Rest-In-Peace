package com.zutalor.containers
{
	import com.gskinner.utils.IDisposable;
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
	public class ViewContainer extends ViewObject implements IDisposable
	{
		public static const HORIZONTAL:String = "horizontal";
		public static const VERTICAL:String = "vertical";
		public static const KEEP:String = "keep";
		public static const GRID:String = "grid";
		
		private var _containerName:String;		
		private var _width:Number;
		private var _height:Number;
		
		public var viewController:ViewController;
				
		public function ViewContainer(containerName:String, width:Number=0, height:Number=0) 
		{
			_containerName = this.name = containerName;
			init(width, height);
		}
		
		private function init(width:Number = 0, height:Number = 0):void
		{
			this.width = width;
			this.height = height;
			cacheAsBitmap = true;
		}
		
		public function callContainerMethod(method:String, params:String):void
		{
			//override this
		}
		
		public function callViewItemMethod(viewItem:String, method:String, params:String):void
		{
			var item:*;
			//TODO check for more errors
			item = viewController.getItemByName(viewItem);
			if (item)
				item[method](params);
			else
				ShowError.fail(ViewContainer,viewItem + " not found on " + name);
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
		
		override public function stop():void 
		{
			if (viewController)
				viewController.stop();
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
		
		public function tweenScrollPercentY(percent:Number, tweenTime:Number = 0.5, ease:Function = null):void
		{
		}
				
		public function tweenScrollPercentX(percent:Number, tweenTime:Number=0.5, ease:Function=null):void
		{
		}
		
		public function set scrollPercentX(percent:Number):void
		{
		}
		
		public function get scrollPercentX():Number
		{
			return 1;
		}
		
		public function set scrollPercentY(percent:Number):void
		{
		}
		
		public function get scrollPercentY():Number
		{
			return 1;
		}	
		
		public function contentChanged(ev:ContainerEvent = null):void
		{
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
			var padding:int = 0;
			var arrange:String = HORIZONTAL;
			
			if ("padding" in options)
				padding = options["padding"];
				
			if ("arrange" in options)	
				arrange = options["arrange"];
				
			for (i = 0; i < numChildren; i++)
			{
				if (arrange == HORIZONTAL)
				{
					if (i) // no front padding on first entry
					{
						width += padding;
					}	
					getChildAt(i).x = width;
					width += getChildAt(i).width;
				}
				else
				{
					if (i) // no front padding on first entry
					{
						height += padding;
					}
					getChildAt(i).y = height;
					height += getChildAt(i).height;
				}
			}
			if (numChildren)
				dispatchEvent(new ContainerEvent(ContainerEvent.CONTENT_CHANGED));
		}
	}
}