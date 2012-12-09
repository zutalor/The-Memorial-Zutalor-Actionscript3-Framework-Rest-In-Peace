package com.zutalor.components.list 
{
	import com.zutalor.components.base.Component;
	import com.zutalor.components.button.Button;
	import com.zutalor.containers.Container;
	import com.zutalor.containers.ScrollingContainer;
	import com.zutalor.gesture.AppGestureEvent;
	import com.zutalor.interfaces.IComponent;
	import com.zutalor.propertyManagers.PropertyManager;
	import com.zutalor.translate.Translate;
	import com.zutalor.view.properties.ViewItemProperties;
	import com.zutalor.view.rendering.ViewLoader;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class List extends Component implements IComponent
	{	
		public static const HORIZONTAL:String = "horizontal";
		public static const VERTICAL:String = "virtical";
		
		private var sc:ScrollingContainer;	
		private var lp:ListProperties;
		private var viewLoader:ViewLoader;
		
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
			sc.removeEventListener(MouseEvent.CLICK, onTap);
			sc.dispose();
			sc = null;
			super.dispose();
		}
		
		// PRIVATE METHODS
		
		private function populateList():void
		{
			var data:Array
			var b:Button;
			
			sc = new ScrollingContainer();
			
			if (lp.url)
				loadData();
			else
			{
				data = lp.data.split(","); 
			
				for (var i:int = 0; i < data.length; i++)
				{
					b = createListItem(data[i]);
					sc.push(b);
				}
			}
			viewLoader.container.addChild(sc);
			sc.scrollWidth= lp.scrollAreaWidth;
			sc.scrollHeight = lp.scrollAreaHeight;
			sc.arranger.autoArrangeChildren( { padding:lp.spacing, orientation:lp.orientation } );
			sc.addEventListener(MouseEvent.CLICK, onTap, false, 0, true);
			addGestureListener("panGesture", onPanGesture);
		}
		
		private function onPanGesture(age:*):void
		{
			if (lp.orientation == HORIZONTAL)
				sc.scrollX += age.gesture.offsetX;
			else
				sc.scrollY += age.gesture.offsetY;	
		}

		private function loadData():void
		{
			//TODO Ideally use a class that does this only.
		}
		
		private function createListItem(text:String):Button
		{
			var b:Button;
			
			b = new Button(name);
			b.vip.text = Translate.text(text);
			b.vip.presetId = lp.itemButtonId;
			b.render();
			return b;
		}
		
		private function onTap(me:MouseEvent):void
		{
			//value = me.target.name;
			//visible = !visible;
			trace(me.target.name);
		}
	}
}