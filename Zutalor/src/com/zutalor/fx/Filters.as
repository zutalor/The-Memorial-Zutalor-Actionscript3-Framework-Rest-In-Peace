package com.zutalor.fx 
{
	import com.gskinner.utils.IDisposable;
	import com.gskinner.utils.Janitor;
	import com.zutalor.properties.DropShadowFilterProperties;
	import com.zutalor.properties.FiltersItemProperties;
	import com.zutalor.properties.FiltersProperties;
	import com.zutalor.properties.GlowFilterProperties;
	import com.zutalor.propertyManagers.NestedPropsManager;
	import com.zutalor.propertyManagers.Presets
	import com.zutalor.properties.RippleProperties;
	import com.zutalor.propertyManagers.Props;
	import com.zutalor.utils.Scale;
	import com.zutalor.utils.StageRef;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Filters implements IDisposable
	{
		public static const SHADOW_PRESET:String = "shadowPreset";
		public static const GLOW_PRESET:String = "glowPreset";
		public static const RIPPLE_PRESET:String = "ripplePreset";
		public static const REFLECTION_PRESET:String = "reflectionPreset";
		public static const LIQUIFY_PRESET:String = "liquifyPreset";
		
		private var _pr:*;
		private var _gRippler:gRippler;
		private var _d:DisplayObject;
		private var _rp:RippleProperties;
		private var _ds:DropShadowFilter;
		private var _gf:GlowFilter;
		
		private static var _filterPresets:NestedPropsManager;
				
		public static function registerPresets(options:Object):void
		{
			if (!_filterPresets)
				_filterPresets = new NestedPropsManager();
			
			_filterPresets.parseXML(FiltersProperties, FiltersItemProperties, options.xml[options.nodeId], options.childNodeId, 
																				options.xml[options.childNodeId]);
		}
		
		public function Filters()
		{
			_filterPresets = Props.filters;
			_pr = Presets;
		}
		
		public function dispose():void
		{
			if (_rp)
			{
				StageRef.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);						
				StageRef.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);						
				StageRef.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);						
				StageRef.stage.removeEventListener(Event.RESIZE, onResize);
				_gRippler.dispose();
				_gRippler = null;
			}			
		}
		
		public function add(d:DisplayObjectContainer, preset:String):void // need to implement all of the filters
		{
			var dfp:DropShadowFilterProperties;
			var gfp:GlowFilterProperties;
			
			var numFilters:int;
			var fp:FiltersProperties;
			var fip:FiltersItemProperties;
			
			var filters:Array = [];

			_d = d;
			fp = _filterPresets.getPropsById(preset);
			
			numFilters = _filterPresets.getNumItems(preset);
			
			for (var i:int = 0; i < numFilters; i++)
			{
				fip = _filterPresets.getItemPropsByIndex(preset, i);
				switch (fip.type)
				{
					case SHADOW_PRESET :
						dfp = _pr.shadowPresets.getPropsByName(fip.preset);
						if (dfp)
						{
							_ds = new DropShadowFilter(dfp.distance,dfp.angle,dfp.color,dfp.alpha,dfp.blurX,dfp.blurY,1,dfp.quality);					
							filters[i] = _ds;
							_d.filters = filters;
						}
						break;
					case GLOW_PRESET :
						gfp = _pr.glowPresets.getPropsByName(fip.preset);
						if (gfp)
						{
							_gf = new GlowFilter(gfp.color, gfp.alpha, gfp.blurX, gfp.blurY, gfp.strength, gfp.quality, gfp.inner, gfp.knockout);
							filters[i] = _gf;	
							_d.filters = filters;
						}
						break;
					case RIPPLE_PRESET :
						if (!_rp) // ignore a try to make two
						{ 
							_rp = _pr.ripplePresets.getPropsByName(fip.preset);
							if (_rp)
							{
								makeNewRipple();
								StageRef.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, false);						
								StageRef.stage.addEventListener(Event.RESIZE, onResize);
							}
						}
						break;
					case REFLECTION_PRESET :
						break; //fix this
						var r:Reflection = new Reflection(d);
						StageRef.stage.addChild(r);
						break;
					case LIQUIFY_PRESET :
						var l:Liquify = new Liquify(d);
						break;
				}
			}
		}
		
		private function makeNewRipple():void
		{
			_gRippler = new gRippler(_d, _rp.strength * Scale.curAppScale, _rp.scaleX * Scale.curAppScale, _rp.scaleY, _rp.fadeTime);
		}
		
		private function onMouseDown(me:MouseEvent):void
		{
			StageRef.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
			
		}		
		
		private function onMouseMove(me:MouseEvent):void
		{
			StageRef.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
			_gRippler.render(_d.mouseX,_d.mouseY, 20 * Scale.curAppScale, .5);
		}
		
		private function onMouseUp(me:MouseEvent):void
		{
			StageRef.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		private function onResize(e:Event):void
		{
			_gRippler.dispose();
			makeNewRipple();
		}
	}
}