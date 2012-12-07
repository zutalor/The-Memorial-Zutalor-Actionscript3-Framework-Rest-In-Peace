package com.zutalor.components.list 
{
	import com.zutalor.components.button.Button;
	import com.zutalor.components.base.Component;
	import com.zutalor.components.embed.Embed;
	import com.zutalor.containers.ViewContainer;
	import com.zutalor.events.UIEvent;
	import com.zutalor.interfaces.IComponent;
	import com.zutalor.containers.ScrollingContainer;
	import com.zutalor.propertyManagers.PropertyManager;
	import com.zutalor.translate.Translate;
	import com.zutalor.utils.MasterClock;
	import com.zutalor.utils.StageRef;
	import com.zutalor.view.controller.ViewController;
	import com.zutalor.view.controller.ViewControllerRegistry;
	import com.zutalor.view.properties.ViewItemProperties;
	import com.zutalor.view.rendering.ViewLoader;
	import com.zutalor.widgets.Dialog;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class List extends Component implements IComponent
	{	
		private var scrollingContainer:ScrollingContainer;	
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
			lp = presets.getPropsByName(vip.presetId);
			viewLoader = new ViewLoader();
			viewLoader.load(lp.listView, null, populateList);
		}
		
		private function populateList():void
		{
			var data:Array;
			scrollingContainer = new ScrollingContainer("list");
			addChild(viewLoader.container);
			addChild(scrollingContainer);
			Dialog.show(Dialog.ALERT, "Test");
			if (lp.url)
				loadData();
			else
			{
				data = lp.data.split(","); 
			
				for (var i:int = 0; i < data.length; i++)
					scrollingContainer.push(createListItem(data[i]));
			}
			scrollingContainer.autoArrangeContainerChildren( { padding:lp.spacing, arrange:lp.arrange } );
			scrollingContainer.addEventListener(MouseEvent.CLICK, onTap, false, 0, true);
		}

		private function loadData():void
		{
			//TODO
		}
		
		private function createListItem(text:String):Button
		{
			var b:Button;
			
			b = new Button(name);
			b.vip.text = Translate.text(text);
			b.vip.presetId = lp.itemButtonId;
			b.vip.width = String(lp.itemWidth);
			b.vip.height = String(lp.itemHeight);
			b.render();
			return b;
		}
		
		private function onTap(me:MouseEvent):void
		{
			value = me.target.name;
			visible = !visible;
			
			trace(value);
		}
	}
}