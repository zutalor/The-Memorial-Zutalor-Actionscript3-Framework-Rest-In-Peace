package com.zutalor.components.list 
{
	import com.zutalor.components.base.Component;
	import com.zutalor.components.button.Button;
	import com.zutalor.containers.scrolling.ScrollingContainer;
	import com.zutalor.gesture.AppGestureEvent;
	import com.zutalor.interfaces.IComponent;
	import com.zutalor.interfaces.IListItemRenderer;
	import com.zutalor.plugin.Plugins;
	import com.zutalor.propertyManagers.PropertyManager;
	import com.zutalor.utils.MasterClock;
	import com.zutalor.view.properties.ViewItemProperties;
	import com.zutalor.view.rendering.ViewLoader;
	import flash.events.MouseEvent;
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class List extends Component implements IComponent
	{			
		public var mouseDownTimeout:int = 1000;

		private var mouseDownTime:int;
		private var sc:ScrollingContainer;	
		private var lp:ListProperties;
		private var viewLoader:ViewLoader;
		private var target:*;
		private var tapped:Boolean;
		
		public var itemRenderer:IListItemRenderer;
		
		public function List(name:String)
		{
			super(name);
		}

		private static var presets:PropertyManager;
		
		public static function registerPresets(options:Object):void
		{	
			if (!presets)
				presets = new PropertyManager(ListProperties);
			
			presets.parseXML(options.xml[options.nodeId]);
		}
			
		override public function render(viewItemProperties:ViewItemProperties = null):void
		{
			super.render(viewItemProperties);
			viewLoader = new ViewLoader(this);
			lp = presets.getPropsByName(vip.presetId);
			viewLoader.load(lp.listView, null, populateList);
		}
		
		override public function dispose():void
		{
			sc.removeGestureListener("tapGesture");
			sc.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			sc.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			sc.dispose();
			sc = null;
			super.dispose();
		}
		
		// PRIVATE METHODS
		
		private function populateList():void
		{
			var itemRendererClass:Class;
									
			sc = new ScrollingContainer(name);	
			
			if (itemRenderer == null)
			{
				itemRendererClass = Plugins.getClass(lp.itemRenderer);
				itemRenderer = new itemRendererClass();
			}
			itemRenderer.render(lp, sc);
			
			MasterClock.callOnce(finish, 200);
			
			function finish():void
			{
				sc.scrollController.scrollWidth = lp.scrollAreaWidth;
				sc.scrollController.scrollHeight = lp.scrollAreaHeight;
				addChild(sc);
				sc.autoArrangeChildren( { padding:0, orientation:lp.orientation } );
				sc.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
				sc.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
				sc.addGestureListener("tapGesture", onTap);
				sc.cacheAsBitmap = true;
			}
		}
		
		private function onMouseUp(me:MouseEvent):void
		{
			trace("click");
			if (tapped && getTimer() - mouseDownTime < mouseDownTimeout)
			{
				value = me.target.name;
				//visible = !visible;
			}
			tapped = false;
		}
		
		private function onMouseDown(me:MouseEvent):void
		{
			mouseDownTime = getTimer();
		}
		
		private function onTap(age:AppGestureEvent):void
		{
			trace("tap");
			tapped = true;
		}
	}
}