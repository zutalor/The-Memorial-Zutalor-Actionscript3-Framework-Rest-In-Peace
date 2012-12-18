package com.zutalor.components.list 
{
	import com.zutalor.components.base.Component;
	import com.zutalor.containers.base.ContainerObject;
	import com.zutalor.containers.scrolling.ScrollingContainer;
	import com.zutalor.events.UIEvent;
	import com.zutalor.interfaces.IComponent;
	import com.zutalor.interfaces.IListItemRenderer;
	import com.zutalor.plugin.Plugins;
	import com.zutalor.propertyManagers.PropertyManager;
	import com.zutalor.utils.FullBounds;
	import com.zutalor.utils.MasterClock;
	import com.zutalor.view.properties.ViewItemProperties;
	import com.zutalor.view.rendering.ViewCreator;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class List extends Component implements IComponent
	{			
		private var sc:ScrollingContainer;	
		private var lp:ListProperties;
		private var viewCreator:ViewCreator;
		private var _scrollRect:Rectangle;
		
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
			_scrollRect = new Rectangle();
			viewCreator = new ViewCreator(this);
			lp = presets.getPropsByName(vip.presetId);
			viewCreator.create(lp.listView, null, populateList);
		}
		
		override public function dispose():void
		{
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
		}	

		private function finish():void
		{
			addChild(sc);
			sc.autoArrangeChildren( { padding:0, orientation:lp.orientation } );
			sc.cacheAsBitmap = true;
			sc.scrollController.width = _scrollRect.width = lp.panAreaWidth;
			sc.scrollController.height = _scrollRect.height = lp.panAreaHeight;
			sc.scrollRect = _scrollRect;
			sc.scrollController.quantizeHPosition = lp.quantizeHPosition;
			sc.scrollController.quantizeVPosition = lp.quantizeVPosition;
			sc.scrollController.contentChanged(sc.getChildAt(0) as ContainerObject, FullBounds.get(sc), onPositionUpdate);
			sc.scrollController.addEventListener(UIEvent.TAP, onTap);
		}
		
		protected function onPositionUpdate(p:Point):void
		{
			_scrollRect.x = p.x;
			_scrollRect.y = p.y;
			sc.scrollRect = _scrollRect;
		}
		
		private function onTap(e:Event):void
		{
			trace("click");
			//value = e.target.name;
				//visible = !visible;
		}
	}
}