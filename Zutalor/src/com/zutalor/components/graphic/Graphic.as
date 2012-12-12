package com.zutalor.components.graphic
{
	import com.zutalor.color.Color;
	import com.zutalor.components.base.Component;
	import com.zutalor.components.embed.Embed;
	import com.zutalor.interfaces.IComponent;
	import com.zutalor.components.label.Label;
	import com.zutalor.containers.base.ContainerObject;
	import com.zutalor.fx.Filters;
	import com.zutalor.fx.Transition;
	import com.zutalor.objectPool.ObjectPool;
	import com.zutalor.propertyManagers.NestedPropsManager;
	import com.zutalor.propertyManagers.PropertyManager;
	import com.zutalor.translate.Translate;
	import com.zutalor.utils.MasterClock;
	import com.zutalor.utils.Resources;
	import com.zutalor.utils.ShowError;
	import com.zutalor.view.properties.ViewItemProperties;
	import flash.display.Graphics;
	import flash.display.GraphicsPathCommand;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Graphic extends Component implements IComponent
	{
		public static const LABEL:String = "label";
		public static const BOX:String = "box";
		public static const ELIPSE:String = "elipse";
		public static const CIRCLE:String = "circle";
		public static const PATH:String = "path";
		public static const EMBED:String = "embed";
		public static const GRAPHIC:String = "graphic";

		public var onLifeTimeCompleteCallback:Function;
		public var onRenderCompleteCallback:Function;

		private static var _stylePresets:PropertyManager;
		private static var _graphics:NestedPropsManager;
	
		private var itemIndex:int;
		private var numItems:int;
		private var _width:int;
		private var _height:int;
		
		public function Graphic(name:String)
		{
			super(name);
		}

		public static function registerStylePresets(options:Object):void
		{
			if (!_stylePresets)
				_stylePresets = new PropertyManager(GraphicStyleProperties);
				
			_stylePresets.parseXML(options.xml[options.nodeId]);
			
		}
		
		public static function registerGraphicPresets(options:Object):void
		{
			if (!_graphics)
				_graphics = new NestedPropsManager();
			
			_graphics.parseXML(GraphicProperties, GraphicItemProperties, options.xml[options.nodeId], options.childNodeId, 
																							options.xml[options.childNodeId]);
		}
		
		override public function render(viewItemProperties:ViewItemProperties = null):void
		{	
			super.render(viewItemProperties);
			if (vip.transitionDelay)
				MasterClock.callOnce(_render, vip.transitionDelay * 1000);
			else
				_render();
		}
		
		private function _render():void
		{
			var grp:GraphicProperties;
			
			grp = _graphics.getPropsById(vip.presetId);
			numItems = _graphics.getNumItems(vip.presetId);
			
			if (numItems == 0)
				ShowError.fail(Graphic,"No items to render for: " + vip.presetId);
				
			renderNextItem();			
		}	
		
		private function renderNextItem():void
		{
			if (itemIndex == numItems)
				onRenderFinished();
			else
				renderItem();
		}
		
		private function renderItem():void
		{
			var item:ContainerObject;
			var gri:GraphicItemProperties;
			gri = _graphics.getItemPropsByIndex(vip.presetId, itemIndex);
			
	
			if (!gri)
				trace(Graphic, "No preset graphic id " + vip.presetId);
			else
			{
				switch (gri.type)
				{
					case Graphic.EMBED :
						item = embed(gri);
						break;
					case Graphic.LABEL :	
						item = label(gri);
						break;	
					case Graphic.GRAPHIC : // nested graphic!
						item = graphic(gri);
						break;
					default :
						item = draw(gri);
						break;
				}
				onItemRenderComplete(item, gri);
				addChild(item);
			}
		}
				
		private function onItemRenderComplete(item:ContainerObject, gri:GraphicItemProperties):void 
		{
			if (gri.rotation)
				item.rotationAroundCenter = gri.rotation;
			
			if (gri.width)
				item.width = gri.width;
			
			if (gri.height)
				item.height = gri.height;
			
			if (gri.blendMode)
				item.blendMode = gri.blendMode;
				
			if (gri.scale)
				item.scaleX = item.scaleY = gri.scale;			
				
			if (gri.filterPreset)
			{
				var filters:Filters = new Filters();
				filters.add(this, gri.filterPreset);		
			}

			if (gri.scale9Data)
				item.scale9Grid = getScale9GridRect(gri.scale9Data); 
				
			if (gri.align && (_width + _height))
				aligner.alignObject(item, _width, _height, gri.align, gri.hPad, gri.vPad);
			else	
			{
				item.x += gri.hPad;
				item.y += gri.vPad;
			}	
			
			itemIndex++;
			renderNextItem();
		}
		
		private function onRenderFinished():void
		{
			var grp:GraphicProperties;
			grp = _graphics.getPropsById(vip.presetId);
			
			if (grp.maskId)
			{
				var mask:Graphic = new Graphic(vip.name);
				vip.presetId = grp.maskId;
				mask.render(vip);
				addChild(mask);
				mask.x = grp.maskX;
				mask.y = grp.maskY;
				this.mask = mask;
			}
			
			if (grp.lifeTime)
				MasterClock.callOnce(transitionOut, grp.lifeTime * 1000);
				
			if (onRenderCompleteCallback != null)
					onRenderCompleteCallback();	
			
			function transitionOut():void
			{
				var t:Transition = ObjectPool.getTransition();
				t.simpleRender(this, grp.transitionOut, "out", finish);
			}
			
			function finish():void
			{
				if (onLifeTimeCompleteCallback != null)
					onLifeTimeCompleteCallback();
			}
		}		
		
		private function draw(gri:GraphicItemProperties):ContainerObject
		{
			var item:ContainerObject = new ContainerObject();
			var coordsStr:Array;
			var commandsStr:Array;
			var commands:Vector.<int>;
			var coords:Vector.<Number>;
			var c:int;
						
			coords = new Vector.<Number>;
			
			
			if (!gri.data)
				return item;
				
			coordsStr =  gri.data.split(",");
			for (var i:int = 0; i < coordsStr.length; i++)
				coords.push(int(coordsStr[i]));
			
			setGraphicStyle(item, gri);
				
			switch (gri.type)
			{
				case Graphic.BOX :
					if (coords.length == 4) // adds the rounded corner param; in this case no corners.
					{
						coords.push(0);
						coords.push(0);
					}	
					item.graphics.drawRoundRect(coords[0], coords[1], coords[2], coords[3], coords[4], coords[5]);
					break;
				case Graphic.ELIPSE :
					item.graphics.drawEllipse(coords[0], coords[1], coords[2], coords[3]);
					break;
				case Graphic.CIRCLE :
					item.graphics.drawCircle(coords[0], coords[1], coords[2]);
					break;
				case Graphic.PATH :	
					commands = new Vector.<int>;
					if (gri.commands)
					{
						commandsStr = gri.commands.split(","); 
						for (i = 0; i < commandsStr.length; i++)
							commands.push(commandsStr[i]);
					}
					else
					{
						commands.push(1);
						c = (coords.length / 2) - 1;
						for (i = 0; i < c; i++)
							commands.push(2);
					}
					item.graphics.drawPath(commands, coords);
					break;
			}
			return item;
		}
		
		private function graphic(gri:GraphicItemProperties):ContainerObject
		{
			var gr:Graphic = new Graphic(vip.name);
			
			if (!gri.data)
				ShowError.fail(Graphic, "data null for " + vip.presetId);
			
			gr.vip.presetId = gri.presetId;
			gr.render();	
			return gr;
		}
		
		private function embed(gri:GraphicItemProperties):ContainerObject
		{
			var em:Embed;
			
			em = new Embed(gri.name);
			em.vip.className = gri.className;
			em.render();
			em.x = int(gri.hPad);
			em.y = int(gri.vPad);
			return em;
		}
		
		private function label(gri:GraphicItemProperties):ContainerObject
		{
			var label:Label = new Label(vip.name);
			label.vip.text = Translate.text(gri.tKey);
			label.vip.textAttributes  = gri.textAttributes;
			label.vip.width = String(gri.width);
			label.vip.height = String(gri.height);
			label.vip.hPad = gri.hPad;
			label.vip.vPad = gri.vPad;
			label.render();
			return (label)
		}
		
		private function setGraphicStyle(item:Sprite, gri:GraphicItemProperties):void
		{
			var g:Graphics = item.graphics;
			var grs:GraphicStyleProperties;
			var lineColor:uint;
			var fillColor:uint;
			
			grs = _stylePresets.getPropsByName(gri.graphicStyle)
			if (!grs)
			{
				trace(Graphics, "No graphics style: " + gri.graphicStyle);
				return;
			}
			
			fillColor = getColor(grs.fillColor);
			lineColor = getColor(grs.lineColor);
				
			function getColor(color:String):uint
			{		
				if (color && color.indexOf("0x") == -1)
					return Color.getColor(Color.theme, color);
				else
					return uint(color);		
			}
			
			if (grs.thickness)
				g.lineStyle(grs.thickness, lineColor, grs.lineAlpha, false, grs.scaleMode, grs.caps, grs.joints);
			
			if (grs.fillClassName)
				g.beginBitmapFill(Resources.createInstance(grs.fillClassName).bitmapData, null, grs.fillRepeat);
			else if (grs.fillType)
			{
				var matrix:Matrix = new Matrix();
				var data:Array = gri.data.split(",");		
				if (data && data.length >= 4)
				{
					matrix.createGradientBox(data[2],data[3], grs.rotation * Math.PI/180);							
					g.beginGradientFill(grs.fillType, grs.colorsArray, grs.alphasArray, grs.ratiosArray, matrix, grs.spreadMethod);
				}
			}
			else if (grs.fillAlpha)
				g.beginFill(fillColor, grs.fillAlpha);
			
			if (grs.alpha)
					item.alpha = grs.alpha;
		}
		
		private function getScale9GridRect(scale9DataString:String):Rectangle
		{
			var scale9Data:Array;
			
			if (scale9DataString)
			{
				scale9Data = scale9DataString.split(",");
				for (var i:int = 0; i < scale9Data.length; i++)
					scale9Data[i] = int(scale9Data[i]);
					
				return new Rectangle(scale9Data[0], scale9Data[1], scale9Data[2], scale9Data[3]);
			}	
			else
				return null;
		}
	}
}