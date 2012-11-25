package com.zutalor.view.rendering
{
import com.zutalor.components.Button;
import com.zutalor.components.Component;
import com.zutalor.components.ComponentGroup;
import com.zutalor.components.Embed;
import com.zutalor.components.Graphic;
import com.zutalor.components.RadioGroup;
import com.zutalor.components.Slider;
import com.zutalor.components.Stepper;
import com.zutalor.components.Toggle;
import com.zutalor.containers.ViewContainer;
import com.zutalor.containers.WebContainer;
import com.zutalor.events.MediaEvent;
import com.zutalor.media.FlipBook;
import com.zutalor.media.MediaPlayer;
import com.zutalor.media.Playlist;
import com.zutalor.media.SlideShow;
import com.zutalor.objectPool.ObjectPool;
import com.zutalor.plugin.constants.PluginClassNames;
import com.zutalor.plugin.Plugins;
import com.zutalor.properties.ApplicationProperties;
import com.zutalor.properties.MediaProperties;
import com.zutalor.properties.TextAttributeProperties;
import com.zutalor.properties.ViewItemProperties;
import com.zutalor.properties.ViewProperties;
import com.zutalor.propertyManagers.Presets;
import com.zutalor.propertyManagers.Props;
import com.zutalor.text.TextUtil;
import com.zutalor.text.Translate;
import com.zutalor.utils.Logger;
import com.zutalor.utils.Resources;
import com.zutalor.utils.ShowError;
import com.zutalor.view.controller.ViewController;
import com.zutalor.view.utils.ViewUtils;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.media.Camera;
import flash.media.Video;
import flash.text.TextField;

	public class ViewRenderer
	{
		private var _pr:Presets;
		private var _ap:ApplicationProperties;

		
		private var _tabIndex:int;
		private var _onItemRenderCallback:Function;
		
		public var vc:ViewController;
		public var vp:ViewProperties;
		public var vu:ViewUtils;
		
		private var _viewItemFilterApplier:ViewItemFilterApplier;
								
		public function ViewRenderer(viewController:ViewController, onItemRenderCallback:Function) 
		{	
			_onItemRenderCallback = onItemRenderCallback;
			vc = viewController;
			_pr = Props.pr;
			_ap = ApplicationProperties.gi();
			_viewItemFilterApplier = new ViewItemFilterApplier(vc);
		}
		
		public function renderItem(itemIndex:int):void
		{
			var tap:TextAttributeProperties;
			var mpp:MediaProperties;
			var width:int;
			var height:int;
			var x:Number;
			var y:Number;
			var hPad:Number;
			var vPad:Number;
			var s:String;
			var c:ViewContainer;
			var txt:TextField;
			var viewItem:*;
			var ViewItemClass:Class;
			var vip:ViewItemProperties;
			var scaleAdjust:Number;
	
			var bm:Bitmap;
			var text:String = "";
			vip = Props.views.getItemPropsByIndex(vc.viewId, itemIndex);
			
			width = int(vip.width);
			height = int(vip.height);
			x = int(vip.x);
			y = int(vip.y);
			hPad = int(vip.hPad);
			vPad = int(vip.vPad);
			
			s = "";
			c = vc.vp.container;
				
			c.visible = true;	
			vc.containergDictionary.insert(c.name, c);
		
			if (vip.tKey)
				text = Translate.text(vip.tKey);
			else
				text = vip.text;
				
			if (!vip.styleSheetName)
				vip.styleSheetName = vp.styleSheetName;
				
			vc.disabledList[itemIndex] = true;
			
			ViewItemClass = Plugins.getClass(vip.type);
			
			switch (ViewItemClass)
			{
						
				case MediaPlayer :
					viewItem = new ViewItemClass();
					mpp = _pr.mediaPresets.getPropsByName(vip.mediaPreset);
					if (!mpp)
						ShowError.fail(ViewRenderer,"View Renderer: video item needs a media preset in xml: " + vip.url);
						
					viewItem.load(vip.url, mpp.volume, width, height, mpp.scaleToFit, 7);
					if (mpp.controlsViewId)
						viewItem.initTransport(mpp.controlsViewId, mpp.controlsContainerName);
					
					
					if (vip.url)
					{
						if (mpp.hideOnPlayComplete)
							viewItem.addEventListener(MediaEvent.COMPLETE, hideMediaPlayerOnPlayComplete, false, 0, true);

						if (mpp.autoPlay)
							viewItem.play(mpp.mediaFadeIn, mpp.audioFadeIn, mpp.fadeOut, 0, mpp.startDelay);
					}
					else
						viewItem.visible = false;
					break;	
				case SlideShow :
					viewItem = new SlideShow();
					if (vip.mediaPreset)
					{
							mpp = _pr.mediaPresets.getPropsByName(vip.mediaPreset);
							if (mpp)
								viewItem.initialize(mpp.controlsViewId, mpp.controlsContainerName);
							else
								ShowError.fail(ViewRenderer,vip.name + " no media preset properties.");
					}
					viewItem.load(vip.url, vip.path, width, height, mpp.backgroundColor, mpp.slideDelay, mpp.crossFade, mpp.autoPlay);
					break;					
				case FlipBook :
					viewItem = new FlipBook();
					if (vip.mediaPreset)
					{
							mpp = _pr.mediaPresets.getPropsByName(vip.mediaPreset);
							if (mpp)
								viewItem.initialize(mpp.controlsViewId);
							else
								ShowError.fail(ViewRenderer,vip.name + " no media preset properties.");
					}
					
					viewItem.load(vip.url, vip.path, width, height, int(vip.data), mpp.urlExtension, mpp.backgroundColor, mpp.fps, mpp.autoPlay);
					break;
				case WebContainer :
					viewItem = new WebContainer("web", width, height, vip.url)
					break;
				default : 
					viewItem = new ViewItemClass(vip);
					break;
			}
			if (!vip.excludeFromDisplayList) 
				c.push(viewItem);

			viewItem.name = vip.name;
			vc.itemDictionary.insert(vip.name, viewItem);
			_viewItemFilterApplier.applyFilters(vip, viewItem);
			vc.viewItemPositioner.positionItem(vip);
			if (vip.tabIndex)
			{
				viewItem.tabEnabled = true;
				viewItem.tabIndex = vip.tabIndex;
				viewItem.focusRect = true;
			}	
			_onItemRenderCallback();

			// VIDEO PLAY COMPLETE
			
			function hideMediaPlayerOnPlayComplete(me:MediaEvent):void
			{
				me.target.visible = false;
			}
		}
	}
}