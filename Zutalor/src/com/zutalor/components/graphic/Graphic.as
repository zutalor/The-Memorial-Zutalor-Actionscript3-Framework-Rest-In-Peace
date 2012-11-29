package com.zutalor.components.graphic
{
	import com.greensock.loading.core.DisplayObjectLoader;
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
	import com.zutalor.sprites.CenterSprite;
	import com.zutalor.text.Translate;
	import com.zutalor.utils.MasterClock;
	import com.zutalor.utils.Resources;
	import com.zutalor.utils.ShowError;
	import com.zutalor.view.properties.ViewItemProperties;
	import flash.display.DisplayObject;
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

		public var onLifeTimeComplete:Function;
		public var onRenderComplete:Function;

		private static var _stylePresets:PropertyManager;
		private static var _graphics:NestedPropsManager;
		
		
		private var grs:GraphicStyleProperties;
		private var grp:GraphicProperties;			
		private var grm:NestedPropsManager;
		private var g:Graphics;
		
		private var scale9Data:Array;
		private var numGraphics:int;
		private var scale9Rect:Rectangle;
		private var i:int = 0;
		
		public static function register(styles:XMLList, xml:XML):void
		{
			if (!_stylePresets)
				_stylePresets = new PropertyManager(GraphicStyleProperties);
				
			if (!_graphics)
				_graphics = new NestedPropsManager();
			
			_stylePresets.parseXML(styles);
			_graphics.parseXML(GraphicProperties, GraphicItemProperties, xml.graphics, "graphic", xml.graphic, "props");
		}
					
		override public function set value(v:*):void
		{
			super.value = v;
			if (_label)
				_label.value = v;
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
			alpha = 1;
			visible = true;
			g = graphics;
			grm = _graphics;
			numGraphics = grm.getNumItems(vip.presetId);
			
			if (numGraphics == 0)
				ShowError.fail(Graphic,"Graphic Render, no items for: " + vip.presetId);
				
			renderNextItem();			
		}	
		
		private function renderNextItem():void
		{
			var item:DisplayObject;
			var gri:GraphicItemProperties;			
			
			if (i == numGraphics)
			{
				if (onRenderComplete != null)
					onRenderComplete();
			}
			else
			{
				gri = grm.getItemPropsByIndex(vip.presetId, i);
				if (!gri)
					ShowError.fail(Graphic, "No properties for graphic id " + vip.presetId);

				switch (gri.type)
				{
					case Graphic.EMBED :
						embed(gri);
						break;
					case Graphic.LABEL :	
						label(gri);
						break;	
					case Graphic.GRAPHIC : // nested graphic!
						graphic(gri);
						break;
					default :
						draw(gri);
						break;
				}
				onItemRenderComplete();
			}
		}
		
		private function draw(gri:GraphicItemProperties):DisplayObject
		{
			var item:CenterSprite = new CenterSprite();
			var data:Array;
			var g:Graphics;
			
			data =  gri.data.split(",");
				
			for (var e:int = 0; e < data.length; e++)
				data[e] = int(data[e]);
			
			data[0] += int(gri.hPad);
			data[1] += int(gri.vPad);
			
			if (scale9Data)
			{
				scale9Data[0] += int(gri.hPad);
				scale9Data[1] += int(gri.hPad);
			}
				
			switch (gri.type)
			{
				case Graphic.BOX :
					drawBox(gri);
					break;
				case Graphic.ELIPSE :
					g.drawEllipse(data[0], data[1], data[2], data[3]);
					break;
				case Graphic.CIRCLE :
					g.drawCircle(data[0], data[1], data[2]);
					break;
			}
			
			if (gri.rotation)
				item.rotationAroundCenter = gri.rotation;
			
			function drawBox():CenterSprite
			{
				if (gri.scale9Data)
				{	
					scale9Data = Vector.<int>(gri.scale9Data.split(","));
					scale9Rect = new Rectangle(scale9Data[0], scale9Data[1], scale9Data[2], scale9Data[3]); 	
				}
				
				if (data.length == 4)
				{
					data.push(0);
					data.push(0);
				}	
				
				g.drawRoundRect(data[0], data[1], data[2], data[3], data[4], data[5]);
				if (scale9Rect)
					item.scale9Grid = scale9Rect;
			}				
		}
		

		private function graphic(gri:GraphicItemProperties):DisplayObject
		{
			var gr:Graphic = new Graphic();
			
			if (!gri.data)
				ShowError.fail(Graphic, "data null for " + vip.presetId);
			
			gr.render(vip);	
			addChild(gr);
		}
		
		private function embed(gri:GraphicItemProperties):DisplayObject
		{
			var em:Embed;
			
			em = new Embed();
			em.vip.className = gri.className;
			em.render();
			em.x = int(gri.hPad);
			em.y = int(gri.vPad);
			addChild(em);
		}
		
		private function label(gri:GraphicItemProperties):DisplayObject
		{
			var:label = new Label();
			label.vip.text = Translate.text(gri.tKey);
			label.vip.width = String(gri.width);
			label.vip.height = String(gri.height);
			label.vip.align = gri.align;
			label.vip.hPad = gri.hPad;
			label.vip.vPad = gri.vPad;
			label.render();
			addChild(label);
		}
		
		
		
		private function setupData():void
		{
			
		}
		
		private function setGraphicStyle(item:Sprite, graphicStyle:String):void
		{
			grs = _stylePresets.getPropsByName(graphicStyle);
			
			var g:Graphics = item.graphics;
			
			if (grs.thickness)
				g.lineStyle(grs.thickness, grs.lineColor, grs.lineAlpha, false, grs.scaleMode, grs.caps, grs.joints);
			
			if (grs.fillClassName)
				g.beginBitmapFill(Resources.createInstance(grs.fillClassName).bitmapData, null, grs.fillRepeat);
			else if (grs.fillType)
			{
				var matrix:Matrix = new Matrix();
						
				matrix.createGradientBox(data[2],data[3], grs.rotation * Math.PI/180);							
				g.beginGradientFill(grs.fillType, grs.colorsArray, grs.alphasArray, grs.ratiosArray, matrix, grs.spreadMethod);
			}
			else if (grs.fillAlpha)
				g.beginFill(grs.fillColor, grs.fillAlpha);		
		}				
		
		private function addPositionOffsets():void
		{
			
		}
		
		private function onItemRenderComplete():void 
		{
			grp = grm.getPropsById(vip.presetId);
			
			if (gri.width)
				
			
			if (grp.maskId)
			{
				var mask:Graphic = new Graphic();
				vip.presetId = grp.maskId;
				mask.render(vip);
				addChild(mask);
				mask.x = grp.maskX;
				mask.y = grp.maskY;
				mask = mask;
			}
			
			if (grp.lifeTime)
				MasterClock.callOnce(transitionOut, grp.lifeTime * 1000);
			
			if (gri.scale)
				scaleX = scaleY = gri.scale;
			
			if (grs)
			{
				if (grs.alpha)
					alpha = grs.alpha;
						
				if (grs.fillAlpha || grs.fillLibraryName || grs.fillType)
					g.endFill();
			}
			
			if (gri.blendMode)
				blendMode = gri.blendMode;
				
			if (gri.filterPreset)
			{
				var filters:Filters = new Filters();
				filters.add(this, gri.filterPreset);		
			}
			
			i++;
			renderNextItem();
		}
		
		private function transitionOut():void
		{
			var t:Transition = ObjectPool.getTransition();
			t.simpleRender(this, grp.transitionOut, "out", finish);
			
			function finish():void
			{
				onLifeTimeComplete();
			}
		}		
	}
}