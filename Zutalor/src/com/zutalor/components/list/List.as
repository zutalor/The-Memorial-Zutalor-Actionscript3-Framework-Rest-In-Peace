package com.zutalor.components.list 
{
	import com.zutalor.components.base.Component;
	import com.zutalor.containers.base.ContainerObject;
	import com.zutalor.containers.Container;
	import com.zutalor.events.UIEvent;
	import com.zutalor.interfaces.IComponent;
	import com.zutalor.interfaces.IListItemRenderer;
	import com.zutalor.plugin.Plugins;
	import com.zutalor.propertyManagers.PropertyManager;
	import com.zutalor.scroll.ScrollController;
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
		private var c:Container;	
		private var lp:ListProperties;
		private var viewCreator:ViewCreator;
		private var _scrollRect:Rectangle;
		private var scrollController:ScrollController;
		
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
			c.dispose();
			c = null;
			super.dispose();
		}
		
		// PRIVATE METHODS
		
		private function populateList():void
		{
			var itemRendererClass:Class;
			c = new Container(name);	
			scrollController = new ScrollController(c);

			if (itemRenderer == null)
			{
				itemRendererClass = Plugins.getClass(lp.itemRenderer);
				itemRenderer = new itemRendererClass();
			}
			itemRenderer.render(lp, c);
			
			MasterClock.callOnce(finish, 200);
		}	

		private function finish():void
		{
			var child:ContainerObject;
			var r:Rectangle;
			
			addChild(c);
			c.autoArrangeChildren( { padding:0, orientation:lp.orientation } );
			c.cacheAsBitmap = true;		
			scrollController.quantizeHPosition = lp.quantizeHPosition;
			scrollController.quantizeVPosition = lp.quantizeVPosition;
			_scrollRect.width = lp.scrollAreaWidth;
			_scrollRect.height = lp.scrollAreaHeight;
			scrollController.slipFactor = .3;
			scrollController.onPositionUpdate(onPositionUpdate);
			c.scrollRect = _scrollRect;
			child = c.getChildAt(0) as ContainerObject;
			r = FullBounds.get(c);
			scrollController.initialize(r.width, r.height, lp.scrollAreaWidth, lp.scrollAreaHeight, child.width, child.height);
			scrollController.addEventListener(UIEvent.TAP, onTap);
		}
		
		protected function onPositionUpdate(p:Point, o:*):void
		{
			_scrollRect.x = p.x;
			_scrollRect.y = p.y;
			c.scrollRect = _scrollRect;
		}
		
		private function onTap(e:Event):void
		{
			trace("click");
			//value = e.target.name;
				//visible = !visible;
		}
	}
}