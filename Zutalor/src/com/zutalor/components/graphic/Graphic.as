package com.zutalor.components.graphic
{
	import com.zutalor.components.Component;
	import com.zutalor.components.embed.Embed;
	import com.zutalor.components.interfaces.IComponent;
	import com.zutalor.components.label.Label;
	import com.zutalor.containers.ViewObject;
	import com.zutalor.fx.Filters;
	import com.zutalor.fx.Transition;
	import com.zutalor.objectPool.ObjectPool;
	import com.zutalor.propertyManagers.NestedPropsManager;
	import com.zutalor.propertyManagers.PropertyManager;
	import com.zutalor.text.Translate;
	import com.zutalor.utils.DisplayUtils;
	import com.zutalor.utils.MasterClock;
	import com.zutalor.utils.Resources;
	import com.zutalor.utils.ShowError;
	import com.zutalor.view.properties.ViewItemProperties;
	import flash.display.Graphics;
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
		
		public static function register(styles:XMLList, xml:XML):void
		{
			if (!_stylePresets)
				_stylePresets = new PropertyManager(GraphicStyleProperties);
				
			if (!_graphics)
				_graphics = new NestedPropsManager();
			
			_stylePresets.parseXML(styles);
			_graphics.parseXML(GraphicProperties, GraphicItemProperties, xml.graphics, "graphic", xml.graphic, "props");
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
			var item:ViewObject;
			var gri:GraphicItemProperties;
			gri = _graphics.getItemPropsByIndex(vip.presetId, itemIndex);
			
			if (!gri)
				trace(Graphic, "No properties for graphic id " + vip.presetId + " : graphic id : " + gri.presetId);
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
				
		private function onItemRenderComplete(item:ViewObject, gri:GraphicItemProperties):void 
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
				DisplayUtils.alignInRect(item, _width, _height, gri.align, gri.hPad, gri.vPad);
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
				var mask:Graphic = new Graphic();
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
		
		private function draw(gri:GraphicItemProperties):ViewObject
		{
			var item:ViewObject = new ViewObject();
			var data:Array;
			
			if (!gri.data)
				ShowError.fail(Graphic, "No graphic item properties for: " + gri.name);
			
			data =  gri.data.split(",");
			for (var i:int = 0; i < data.length; i++)
				data[i] = int(data[i]);
			
			setGraphicStyle(item, gri);
				
			switch (gri.type)
			{
				case Graphic.BOX :
					if (data.length == 4) // adds the rounded corner param; in this case no corners.
					{
						data.push(0);
						data.push(0);
					}	
					item.graphics.drawRoundRect(data[0], data[1], data[2], data[3], data[4], data[5]);
					break;
				case Graphic.ELIPSE :
					item.graphics.drawEllipse(data[0], data[1], data[2], data[3]);
					break;
				case Graphic.CIRCLE :
					item.graphics.drawCircle(data[0], data[1], data[2]);
					break;
			}
			return item;
		}
		
		private function graphic(gri:GraphicItemProperties):ViewObject
		{
			var gr:Graphic = new Graphic();
			
			if (!gri.data)
				ShowError.fail(Graphic, "data null for " + vip.presetId);
			
			gr.vip.presetId = gri.presetId;
			gr.render();	
			return gr;
		}
		
		private function embed(gri:GraphicItemProperties):ViewObject
		{
			var em:Embed;
			
			em = new Embed();
			em.vip.className = gri.className;
			em.render();
			em.x = int(gri.hPad);
			em.y = int(gri.vPad);
			return em;
		}
		
		private function label(gri:GraphicItemProperties):ViewObject
		{
			var label:Label = new Label();
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
			
			grs = _stylePresets.getPropsByName(gri.graphicStyle)
			if (!grs)
			{
				trace(Graphics, "No graphics style: " + gri.graphicStyle);
				return;
			}
			
			if (grs.thickness)
				g.lineStyle(grs.thickness, grs.lineColor, grs.lineAlpha, false, grs.scaleMode, grs.caps, grs.joints);
			
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
				g.beginFill(grs.fillColor, grs.fillAlpha);
			
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