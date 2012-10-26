package com.zutalor.view
{
import com.zutalor.containers.StandardContainer;
import com.zutalor.containers.WebContainer;
import com.zutalor.events.MediaEvent;
import com.zutalor.fx.Filters;
import com.zutalor.media.FlipBook;
import com.zutalor.media.Playlist;
import com.zutalor.media.SlideShow;
import com.zutalor.objectPool.ObjectPool;
import com.zutalor.plugin.constants.PluginClassNames;
import com.zutalor.plugin.Plugins;
import com.zutalor.properties.ApplicationProperties;
import com.zutalor.properties.MediaProperties;
import com.zutalor.properties.ScrollProperties;
import com.zutalor.properties.TextAttributeProperties;
import com.zutalor.properties.ViewItemProperties;
import com.zutalor.properties.ViewProperties;
import com.zutalor.propertyManagers.NestedPropsManager;
import com.zutalor.propertyManagers.Presets;
import com.zutalor.propertyManagers.PropertyManager;
import com.zutalor.propertyManagers.Props;
import com.zutalor.text.TextUtil;
import com.zutalor.text.Translate;
import com.zutalor.ui.Components;
import com.zutalor.ui.Graphic;
import com.zutalor.utils.DisplayObjectUtils;
import com.zutalor.utils.DisplayUtils;
import com.zutalor.utils.Logger;
import com.zutalor.utils.MasterClock;
import com.zutalor.utils.Resources;
import com.zutalor.view.ViewController;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.media.Camera;
import flash.media.Video;
import flash.text.TextField;

	public class ViewRenderer
	{
		private var _vpm:NestedPropsManager;
		private var _pr:Presets;
		private var _ap:ApplicationProperties;
		private var _vu:ViewUtils;
		
		private var _tabIndex:int;
		private var _onItemRenderCallback:Function;
		
		public var vc:ViewController;
		public var vp:ViewProperties;
	
								
		public function ViewRenderer(viewController:ViewController, onItemRenderCallback:Function) 
		{	
			_onItemRenderCallback = onItemRenderCallback;
			vc = viewController;
			_vpm = Props.views;
			_pr = Props.pr;
			_ap = ApplicationProperties.gi();
			_vu = ViewUtils.gi();
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
			var c:StandardContainer;
			var txt:TextField;
			var viewItem:*;
			var vip:ViewItemProperties;
			var scaleAdjust:Number;
			var mask:Graphic;
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
			vc.containergDictionary.addOrReplace(c.name, c);
		
			if (vip.tText)
				text = Translate.text(vip.tText);
			else
				text = "";
				
			vc.disabledList[itemIndex] = true;
			switch (vip.type)
			{
				case ViewItemProperties.TOGGLE :
				case ViewItemProperties.SLIDER :
				case ViewItemProperties.TEXT_BUTTON :
				case ViewItemProperties.BUTTON :
				case ViewItemProperties.STEPPER :
				case ViewItemProperties.COMPONENT_GROUP :
				case ViewItemProperties.RADIO_GROUP :
					vc.disabledList[itemIndex] = false;
					viewItem = Components.getComponent(vip.name, vip.type, vip.componentId, text, vip.dataProvider);
					push(viewItem)
					onItemLoadComplete();
					break;
				case ViewItemProperties.INPUT_TEXT :					
					vc.disabledList[itemIndex] = false;
				case ViewItemProperties.LABEL :
				case ViewItemProperties.STATUS :	
					txt = ObjectPool.getTextField();
					txt.text = text;
					viewItem = txt;
					
					TextUtil.applyTextAttributes(txt, vip.textAttributes, width, height);					
					tap = _pr.textAttributePresets.getPropsByName(vip.textAttributes);						
					
					if (vip.type == ViewItemProperties.STATUS)
					{
						vc.statusField = txt;
					}
					push(txt);
					onItemLoadComplete();	
					break;
				case ViewItemProperties.LIST :
					vc.disabledList[itemIndex] = false;
					var list:* = Plugins.getNewInstance(PluginClassNames.LIST);
					var listProvider:Array = new Array();
					viewItem = list;
					list.width = width;
					list.height = height;
					push(list);
					
					if (vip.url)
						TextUtil.load(vip.url, onListLoadComplete, txt);
					else 
					{
						if (vip.data)
							listProvider = vip.data.split(",");
						else
							listProvider = [];
							
						list.dataProvider = listProvider;
						onItemLoadComplete();
					}
					list.selectedItem = text;

					break;
				case ViewItemProperties.COMBOBOX :
					vc.disabledList[itemIndex] = false;					
					var comboBox:* = Plugins.getNewInstance(PluginClassNames.COMBOBOX);
					var comboProvider:Array = new Array();
					
					viewItem = comboBox;
					comboBox.setSize(width, height);
					push(comboBox);

					if (vip.url)
						TextUtil.load(vip.url, onComboBoxLoadComplete, txt);
					else {
						if (vip.data)
							comboProvider = vip.data.split(",");
						else
							comboProvider = [];
						
						comboBox.dataProvider = comboProvider;
						onItemLoadComplete();
					}
					if (text)
					{
						comboBox.selectedItem = text;				
						comboBox.label = comboBox.selectedItem;
					}
					break;
					
				case ViewItemProperties.EMBED :	
					var e:* = Resources.createInstance(vip.className);
					if (e is Bitmap)
					{
						e.smoothing = true;
						viewItem = new Sprite();
						viewItem.addChild(e);
					}
					
					push(viewItem);
					onItemLoadComplete();
					break;
					
				case ViewItemProperties.HTML :
					vc.disabledList[itemIndex] = false;
					txt = ObjectPool.getTextField();
					viewItem = txt;
					txt.cacheAsBitmap = true;
					push(txt);
					if (vip.url)
					{
						TextUtil.load(vip.url, onHTMLLoadComplete, txt, width, vp.styleSheetName);
					}
					else
					{
						if (text)
						{	
							TextUtil.applyStylesheet(txt, vp.styleSheetName, width);
							txt.htmlText = text;							
						}	
						onHTMLLoadComplete();
					}
					break;
				case ViewItemProperties.VIDEO :
				case ViewItemProperties.YOUTUBE :
				case ViewItemProperties.AUDIO :
					
					var mediaPlayer:*;
									
					switch (vip.type)
					{
						case ViewItemProperties.VIDEO :
							mediaPlayer = Plugins.getNewInstance(PluginClassNames.VIDEO_PLAYER);
							break;
						case ViewItemProperties.YOUTUBE :
							mediaPlayer = Plugins.getNewInstance(PluginClassNames.YOUTUBE_PLAYER);
							break;
						case ViewItemProperties.AUDIO :
							mediaPlayer = Plugins.getNewInstance(PluginClassNames.AUDIO_PLAYER);
							break;
					}
					mpp = _pr.mediaPresets.getPropsByName(vip.mediaPreset);
					if (!mpp)
						throw new Error("View Renderer: video item needs a media preset in model.xml: " + vip.url);
						
					
					mediaPlayer.load(vip.url, mpp.volume, width, height, mpp.scaleToFit, 7);
					if (mpp.controlsViewId)
						mediaPlayer.initTransport(mpp.controlsViewId, mpp.controlsContainerName);
					
					viewItem = mediaPlayer;
					push(mediaPlayer);	
					
					if (vip.url)
					{
						if (mpp.hideOnPlayComplete)
							mediaPlayer.addEventListener(MediaEvent.COMPLETE, hideMediaPlayerOnPlayComplete, false, 0, true);

						if (mpp.autoPlay)
							mediaPlayer.play(mpp.mediaFadeIn, mpp.audioFadeIn, mpp.fadeOut, 0, mpp.startDelay);
					}
					else
						mediaPlayer.visible = false;
						
					onItemLoadComplete();
					break;	
				case ViewItemProperties.BASIC_VIDEO :
					var basicVideo:* = Plugins.getNewInstance(PluginClassNames.BASIC_VIDEO_PLAYER);
					basicVideo.load(vip.url, width, height);
					viewItem = basicVideo;
					push(basicVideo);
					onItemLoadComplete();
					break;
				case ViewItemProperties.CAMERA :
					var cam:Camera = Camera.getCamera();
					var video:Video = new Video(width,height);
					viewItem = video;
					push(viewItem);
					
					if (cam) 
					{
						video.attachCamera(cam);
						cam.setMode(width, height, 12, true);
					}
					else
					{
						Logger.add("No camera found");
					}	
					onItemLoadComplete();						
					break;
				case ViewItemProperties.GRAPHIC :
					var graphic:Graphic = ObjectPool.getGraphic();
					viewItem = graphic;
					graphic.render(vip.graphicId, vip.transitionDelay, onGraphicRenderComplete);
					break;			
				case ViewItemProperties.TWITTER :
					var twitterLoader:* = Plugins.getNewInstance(PluginClassNames.TWITTER_LOADER);
					viewItem = twitterLoader;
					twitterLoader.initialize(vip.url, _ap.proxyLocationUrl, vp.styleSheetName, width, 0, 10, vip.data);	
					push(twitterLoader);
					onItemLoadComplete();				
					break;
				case ViewItemProperties.PLAYLIST :
					if (!vip.playlistName)
						throw new Error("ViewRenderer: Playlist name cannot be null.");
						
					var playlist:Playlist = new Playlist();
					playlist.create(vip.playlistName, vip.name, width, height); 
					playlist.x = x + hPad;
					playlist.y = y = vPad;
					viewItem = playlist;
					//if (vip.onClickUiEvent)
					//	viewItem.buttonMode = true;
					applyFilters();
					push(viewItem);
					viewItem.name = vip.name;	
					vc.itemDictionary.addOrReplace(vip.name, viewItem);
					_onItemRenderCallback();
					break;
				case ViewItemProperties.SLIDE_SHOW :
					var slideShow:SlideShow = new SlideShow();
					if (vip.mediaPreset)
					{
							mpp = _pr.mediaPresets.getPropsByName(vip.mediaPreset);
							if (mpp)
								slideShow.initialize(mpp.controlsViewId, mpp.controlsContainerName);
							else
								throw new Error(vip.name + " no media preset properties.");
					}
					viewItem = slideShow;
					slideShow.load(vip.url, vip.path, width, height, mpp.backgroundColor, mpp.slideDelay, mpp.crossFade, mpp.autoPlay);
					push(viewItem);
					onItemLoadComplete();
					break;
					
				case ViewItemProperties.FLIPBOOK :
					var flipBook:FlipBook = new FlipBook();
					if (vip.mediaPreset)
					{
							mpp = _pr.mediaPresets.getPropsByName(vip.mediaPreset);
							if (mpp)
								flipBook.initialize(mpp.controlsViewId);
							else
								throw new Error(vip.name + " no media preset properties.");
					}
					
					viewItem = flipBook;
					flipBook.load(vip.url, vip.path, width, height, int(vip.data), mpp.urlExtension, mpp.backgroundColor, mpp.fps, mpp.autoPlay);
					push(viewItem);
					onItemLoadComplete();
					break;
				case ViewItemProperties.WEB :
					var webContainer:WebContainer = new WebContainer("web", width, height, vip.url)
					viewItem = webContainer;
					push(viewItem);
					onItemLoadComplete();
					break;
				case ViewItemProperties.PROPERTY : // these are not added to the display list.
					onItemLoadComplete();
					break;
				default : 
					throw new Error("View Renderer: view item has unknown type: " + vip.name + ":" + vip.type);
					break;
			}
		
		//END OF SWITCH				
		// COMPLETING METHODS FOR ITEMS LOADED EXTERNALLY

			function onListLoadComplete():void
			{
				listProvider = txt.text.split(",");
				list.dataProvider = listProvider;
				onItemLoadComplete();
			}

			function onComboBoxLoadComplete():void
			{
				comboProvider = txt.text.split(",");
				comboBox.dataProvider = comboProvider;
				onItemLoadComplete();
			}
			
			function onHTMLLoadComplete():void
			{		
				push(txt);
				c.tweenScrollPercentX(0);
				c.tweenScrollPercentY(0);
				onItemLoadComplete();				
			}
			
			function onGraphicRenderComplete():void 
			{
				push(viewItem);			
				onItemLoadComplete();
			}
						
			// CALLED FOR EACH ITEM LOADED AND/OR INITIALIZED
			
			function push(item:*):void
			{
				if (!vip.excludeFromDisplayList) 
					c.push(item);
			}
			
			function onItemLoadComplete():void
			{	
				if (viewItem)
				{
					positionItem();
					if (vip.tabIndex)
					{
						viewItem.tabEnabled = true;
						viewItem.tabIndex = vip.tabIndex;
						viewItem.focusRect = true;
					}	
				}
				_onItemRenderCallback();
			}
			
			// POSITION, CALL STUFF, MOVE THINGS AROUND
			
			function positionItem():void
			{
				var scrollProperties:ScrollProperties;
		
				if (c != vc.vp.container) // c is a child container
				{
					if (vip.containerX)
						c.x = vip.containerX;

					if (vip.containerY)
						c.y = vip.containerY;
				}

				if (vip.scrollPreset)
				{
					_vu.updateContainerScrollPosition(vip.scrollPreset);
				}
				vc.itemDictionary.addOrReplace(vip.name, viewItem);
				viewItem.name = vip.name;
				
				
				if (vip.align)
					DisplayUtils.alignInRect(viewItem, vc.vp.width, vc.vp.height, vip.align, vip.hPad, vip.vPad);
				else
				{
					viewItem.x = x + hPad;
					viewItem.y = y + vPad;
				}
				
				if (vip.width) // this must happen before other properties are set.
					if (vip.width == "auto")
						viewItem.width = c.width;
					else if (viewItem.width)
						viewItem.width = width;
							
				if (vip.height)
					if (vip.height == "auto")
						viewItem.height = c.height;
					else if (viewItem.height)
						viewItem.height = height;							
				
				if (vip.rotation)
					viewItem.rotation = vip.rotation;
				
				if (vip.rotationX)
					viewItem.rotationX = vip.rotationX;

				if (vip.rotationY)
					viewItem.rotationY = vip.rotationY;

				if (vip.rotationX)
					viewItem.rotationZ = vip.rotationZ;
				
				applyFilters();
				
				if (vip.alpha)
					viewItem.alpha = vip.alpha;
				else
					viewItem.alpha = 1;
	
				if (vip.hidden)
					viewItem.visible = false;
			}
			
			// FILTERS
			
			function applyFilters():void
			{
				if (vip.filterPreset || vip.maskGid)
				{
					if (vip.transitionDelay)
						MasterClock.callOnce(_applyFilters, vip.transitionDelay);
					else
						_applyFilters();						
				}				
			}
			
			function _applyFilters():void
			{
				if (vc.filters)
				{
					var filters:Filters = new Filters();
					vc.filters.push(filters);
					filters.add(viewItem, vip.filterPreset);
				}
				
				if (vip.maskGid)
				{
					mask = new Graphic();
					mask.render(vip.maskGid);
					viewItem.mask = mask;
					viewItem.addChild(mask);
				}		
			}	
			
			// VIDEO PLAY COMPLETE
			
			function hideMediaPlayerOnPlayComplete(me:MediaEvent):void
			{
				me.target.visible = false;
			}
		}
	}
}