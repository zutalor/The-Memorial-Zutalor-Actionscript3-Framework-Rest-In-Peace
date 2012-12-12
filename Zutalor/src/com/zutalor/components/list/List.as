package com.zutalor.components.list 
{
	import com.zutalor.components.base.Component;
	import com.zutalor.components.button.Button;
	import com.zutalor.containers.ScrollingContainer;
	import com.zutalor.gesture.AppGestureEvent;
	import com.zutalor.interfaces.IComponent;
	import com.zutalor.propertyManagers.PropertyManager;
	import com.zutalor.translate.Translate;
	import com.zutalor.utils.MasterClock;
	import com.zutalor.utils.StageRef;
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
			var c:* = this;
			super.render(viewItemProperties);
			
			viewLoader = new ViewLoader(c);
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
			
			if (lp.orientation == HORIZONTAL)
				enableHScroll = true;
			else
				enableYScroll = true;
							
			sc = new ScrollingContainer(name, enableHScroll, enableYScroll);
			
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
			
			addChild(sc);
			sc.cacheAsBitmap = true;
			sc.scrollWidth= lp.scrollAreaWidth;
			sc.scrollHeight = lp.scrollAreaHeight;
			sc.autoArrangeChildren( { padding:lp.spacing, orientation:lp.orientation } );	
			sc.addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
			sc.addGestureListener("tapGesture", onTap);
			StageRef.stage.addChild(sc);

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