package com.zutalor.components.list 
{
	import com.zutalor.components.base.Component;
	import com.zutalor.components.button.Button;
	import com.zutalor.containers.ScrollingContainer;
	import com.zutalor.gesture.AppGestureEvent;
	import com.zutalor.interfaces.IComponent;
	import com.zutalor.interfaces.IListItemRenderer;
	import com.zutalor.plugin.Plugins;
	import com.zutalor.propertyManagers.PropertyManager;
	import com.zutalor.utils.MasterClock;
	import com.zutalor.view.properties.ViewItemProperties;
	import com.zutalor.view.rendering.ViewLoader;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class List extends Component implements IComponent
	{			
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
			sc.removeEventListener(MouseEvent.CLICK, onClick);
			sc.dispose();
			sc = null;
			super.dispose();
		}
		
		// PRIVATE METHODS
		
		private function populateList():void
		{
			var data:Array
			var b:Button;
			var enableHScroll:Boolean;
			var enableYScroll:Boolean;
			var irClass:Class;
			
			if (lp.orientation == HORIZONTAL)
				enableHScroll = true;
			else
				enableYScroll = true;
							
			sc = new ScrollingContainer(name, enableHScroll, enableYScroll);	
			
			if (itemRenderer == null)
			{
				irClass = Plugins.getClass(lp.itemRenderer);
				itemRenderer = new irClass();
			}
			itemRenderer.render(lp, sc);
			
			MasterClock.callOnce(finish, 200); // total hack 
			
			function finish():void
			{
				sc.scrollWidth= lp.scrollAreaWidth;
				sc.scrollHeight = lp.scrollAreaHeight;
				addChild(sc);
				sc.autoArrangeChildren( { padding:lp.spacing, orientation:lp.orientation } );
				sc.addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
				sc.addGestureListener("tapGesture", onTap);
				sc.cacheAsBitmap = true;
			}
		}
		
		private function onClick(me:MouseEvent):void
		{
			if (tapped)
			{
				value = me.target.name;
				visible = !visible;
				tapped = false;
			}
		}
		
		private function onTap(age:AppGestureEvent):void
		{
			tapped = true;
		}
	}
}