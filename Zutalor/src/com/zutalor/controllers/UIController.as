package com.zutalor.controllers
{
	import com.asual.swfaddress.SWFAddress;
	import com.asual.swfaddress.SWFAddressEvent;
	import com.greensock.TweenMax;
	import com.zutalor.air.AirStatus;
	import com.zutalor.amfphp.Remoting;
	import com.zutalor.containers.StandardContainer;
	import com.zutalor.events.AppEvent;
	import com.zutalor.events.HotKeyEvent;
	import com.zutalor.events.UIEvent;
	import com.zutalor.fx.Wind;
	import com.zutalor.loaders.URL;
	import com.zutalor.motion.MotionUtils;
	import com.zutalor.plugin.constants.PluginClasses;
	import com.zutalor.plugin.constants.PluginMethods;
	import com.zutalor.plugin.Plugins;
	import com.zutalor.properties.ApplicationProperties;
	import com.zutalor.properties.MenuProperties;
	import com.zutalor.properties.ViewProperties;
	import com.zutalor.propertyManagers.NestedPropsManager;
	import com.zutalor.propertyManagers.Props;
	import com.zutalor.sequence.Sequence;
	import com.zutalor.text.Translate;
	import com.zutalor.ui.Spinner;
	import com.zutalor.ui.ToolTip;
	import com.zutalor.utils.FullScreen;
	import com.zutalor.utils.gDictionary;
	import com.zutalor.utils.MasterClock;
	import com.zutalor.utils.Resources;
	import com.zutalor.utils.Scale;
	import com.zutalor.utils.StageRef;
	import com.zutalor.view.ViewCloser;
	import com.zutalor.view.ViewLoader;
	import com.zutalor.view.ViewUtils;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageOrientation;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.StageVideoAvailabilityEvent;
	import flash.geom.Rectangle;
	import flash.media.StageVideoAvailability;
	import flash.ui.Mouse;
	
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */

	public class UIController extends EventDispatcher
	{	
		private const DEBUG:Boolean =  false;
		
		private const SYSTEM_FONTS:String = "system-fonts";
		private const APP_FONTS:String = "app-fonts";
		private const APP_PRELOAD:String = "app-preload";
		private const SYSTEM_PRELOAD:String = "system-preload";
		
		private const FULL_SCREEN_INTERACTIVE:String = "fullScreenInteractive";
		
		private var vu:ViewUtils;
		private var mu:MotionUtils;
		private var ip:String;
		
		private var mp:MenuProperties;
		private var curContainerLoading:String;	
		
		private var ap:ApplicationProperties;
		private var vpm:NestedPropsManager;	
			
		private var _loadingSequence:Sequence;
		private var _curViewProps:ViewProperties;
		private var _firstPage:String;
		private var _menuCallStack:gDictionary;
		private var _curMenuSelection:String;
		private var _splashEmbedClassName:String;
		private var _bootXmlUrl:String;
		private var _sheild:Sprite;
		private var _initialized:Boolean;
		private var _currentOrientation:String;

		// CONSTRUCTOR
		
		public function UIController(bootXmlUrl:String,splashClassName:String=null)
		{
			_splashEmbedClassName = splashClassName;
			_bootXmlUrl = bootXmlUrl;
		}
						
		// PUBLIC METHODS
		
		public function init(stage:Stage, ip:String):void
		{	
			if (_initialized)
				return;
				
			this.ip = ip;
			StageRef.stage = stage;		
			if (_splashEmbedClassName)
				showSplash();
				
			MasterClock.initialize();
			MasterClock.defaultInterval = 1000 / StageRef.stage.frameRate;
			Props.init(_bootXmlUrl, initialize);
		}
				
		public function closeView(containerName:String, onComplete:Function = null):void
		{
			var menuSelection:String;
			var cc:ViewCloser;
			
			cc = new ViewCloser();
			cc.close(containerName, onComplete);
			menuSelection = vpm.getPropsById(containerName).menuName;
			if (menuSelection)
			{
				_menuCallStack.deleteByKey(menuSelection);
				menuSelection = _menuCallStack.getKeyByIndex(_menuCallStack.length - 1);
				SWFAddress.setTitle(ap.appName + " - " + menuSelection);
				SWFAddress.setValue(menuSelection);	
				_curViewProps = null;
			}
		}	
		
		public function menuCall(menuSelection:String):void 
		{	
			_curMenuSelection = menuSelection;
			if (_curViewProps && !_curViewProps.contentPersists)
			{
				if (mp.viewId == _curViewProps.name)
					closeView(_curViewProps.container.name, processMenuSelection);
				else 
				{
					closeView(_curViewProps.container.name);
					processMenuSelection();
				}
			}
			else
				processMenuSelection();
		}
		
		public function arrangeUI():void
		{	
			Mouse.show();
			Scale.calcAppScale(StageRef.stage, ap.designWidth, ap.designHeight);
			Scale.constrainAppScaleRatio();
			_sheild.graphics.clear();
			_sheild.graphics.beginFill(0x000000, .2)
			_sheild.graphics.drawRect(0, 0, StageRef.stage.stageWidth, StageRef.stage.stageHeight)
			_sheild.graphics.endFill();
			ap.contentLayer.width = StageRef.stage.stageWidth;
			ap.contentLayer.height = StageRef.stage.stageHeight;
			vu.arrangeAppContainers();
		}						
		
		public function showSheild():void
		{
			ap.contentLayer.addChildAt(_sheild, 0);
		}
		
		public function hideSheild():void
		{
			if (ap.contentLayer.getChildByName("__Sheild"))
				ap.contentLayer.removeChild(_sheild);
		}	
		
		// PRIVATE METHODS

		private function showSplash():void
		{
			var splash:Bitmap;
			splash = Resources.createInstance(_splashEmbedClassName);
			splash.name = "splash";
			StageRef.stage.addChild(splash);
			splash.x = (StageRef.stage.stageWidth - splash.width) * .5;
			splash.y = (StageRef.stage.stageHeight - splash.height) * .5;
			TweenMax.from(splash, 1, { alpha:0 } );
		}
	
		private function onStageVideoAbility(e:StageVideoAvailabilityEvent):void 
		{ 
			ap.stageVideoAvailable = (e.availability == StageVideoAvailability.AVAILABLE);
		}
		
		private function onMenuSelection(uie:UIEvent):void
		{
			menuCallSWFAddress(uie.menuSelection);
		}		
		
		private function onSWFAddressFirstBroadcast(e:SWFAddressEvent):void	
		{
			SWFAddress.removeEventListener(SWFAddressEvent.CHANGE, onSWFAddressFirstBroadcast);	
			_firstPage = e.value.toLowerCase();
			
			if (_firstPage != "/") 
				_firstPage = _firstPage.substring(1); 
			else
				_firstPage = ap.homePage.toLowerCase();
				
			SWFAddress.setTitle(ap.appName + " - " + _firstPage);
		}
		
		private function onSWFAddressChange(e:SWFAddressEvent = null):void	
		{
			var page:String;
	
			page = e.value.toLowerCase();
			if (page != "/")		
				page = page.substring(1);
			
			if (page || int(page) < Props.pr.menu.length)
				menuCall(page);
		}
		
		private function menuCallSWFAddress(menuSelection:String):void 
		{	
			if (menuSelection)
			{
				Mouse.show();
				if (!curContainerLoading)
				{
					menuSelection = menuSelection.toLowerCase();										
					SWFAddress.setTitle(ap.appName + " - " + menuSelection);
					SWFAddress.setValue(menuSelection);	
					if (ap.googleAnalyticsAccount && AirStatus.isNativeApplication || DEBUG)
						Plugins.callMethod(PluginClasses.ANALYTICS, PluginMethods.TRACK_PAGE_VIEW, 
																				{ page:menuSelection } );
				}	
			}
		}	
				
		private function onStageResize(e:Event):void
		{
			if (!ap.ignoreStageResize)
			{
				arrangeUI();
			}
		}
		
		private function checkOrientation():void
		{
			return;
			var orientation:String;
			if (AirStatus.isMobile)
			{
				if (_currentOrientation != StageRef.stage.deviceOrientation)
				{
					switch (StageRef.stage.deviceOrientation)
					{
						case StageOrientation.ROTATED_RIGHT: 
						case StageOrientation.ROTATED_LEFT:
							orientation = StageOrientation.DEFAULT;
							break; 
						case StageOrientation.UPSIDE_DOWN:
							orientation = StageOrientation.UPSIDE_DOWN; 
							break; 
						default: 
							orientation = StageOrientation.DEFAULT; 
							break;
					}
					StageRef.stage.setOrientation(orientation);
					_currentOrientation = orientation;
				}
			}
		}
		
		private function loadFirstPage():void
		{
			if (_firstPage)
			{
				menuCall(_firstPage);
			}
			else
			{
				SWFAddress.setTitle(ap.appName);
				SWFAddress.setValue("");			
			}
			SWFAddress.addEventListener(SWFAddressEvent.CHANGE, onSWFAddressChange);
			dispatchEvent(new AppEvent(AppEvent.INITIALIZED));		}	
		
		private function processMenuSelection():void
		{
			var viewLoader:ViewLoader;
			
			mp = Props.pr.menu.getPropsByName(_curMenuSelection);

			if (!mp)
			{
				SWFAddress.setTitle(ap.appName);
				SWFAddress.setValue("");			
			}
			else
			{
				dispatchEvent(new AppEvent(AppEvent.MENU_CALL));
				switch (mp.type)
				{
					case MenuProperties.LINK :
						URL.open(mp.url);
						menuCallComplete();
						break;	
					case MenuProperties.SEQUENCE :
						_loadingSequence = new Sequence();
						_loadingSequence.play(mp.sequenceName, this, menuCall, menuCallComplete);
						break;
					default :
						if (mp.viewId && !_menuCallStack.getByKey(_curMenuSelection)) 
						{
							_menuCallStack.insert(_curMenuSelection, mp);
							_curViewProps = vpm.getPropsById(mp.viewId);		
							curContainerLoading = _curViewProps.name;
							viewLoader = new ViewLoader();
							if (mp.transitionPreset)
								_curViewProps.transitionPreset = mp.transitionPreset;
							
							_curViewProps.mediaPreset = mp.mediaPreset;
							viewLoader.load(mp.viewId, mp.name, onAppContainerLoadComplete);							
						}
				}				
			}
		}
		
		private function menuCallComplete():void
		{
			vu.updateContainerScrollPosition(mp.scrollPreset);
			mp = null;
			dispatchEvent(new Event(Event.COMPLETE));
		}
				
		private function onAppContainerLoadComplete():void
		{
			if (curContainerLoading)
			{
				_curViewProps = vpm.getPropsById(curContainerLoading);
				curContainerLoading = "";	
				vu.updateContainerScrollPosition(mp.scrollPreset);
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		// INITIALIZATION
		 	
		private function initialize():void
		{
			ap = ApplicationProperties.gi();
			vu = ViewUtils.gi();
			mu = MotionUtils.gi();
			vpm = Props.views;
			ap.ip = ip;
			_sheild = new Sprite;
			_sheild.name = "__Sheild";
			StageRef.stage.addEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, 
																					onStageVideoAbility);	
			SWFAddress.addEventListener(SWFAddressEvent.CHANGE, onSWFAddressFirstBroadcast);			
			MasterClock.initialize();
			Remoting.gateway = ap.gateway;
			_menuCallStack = new gDictionary();	
			ap.contentLayer = new StandardContainer("contentLayer", ap.designWidth, ap.designHeight);
			
			StageRef.stage.addChild(ap.contentLayer);			
			Translate.language = Props.ap.language;

			if (ap.spinningGraphicId)
				Spinner.init(ap.spinningGraphicId, ap.spinningGraphicCyclesPerSecond);
				
			if (ap.enableWind)
				Wind.start();
			
			if (ap.enableMotionChecking)
				mu.enableMotionChecking();
			
			if (ap.googleAnalyticsAccount && AirStatus.isNativeApplication || DEBUG)
			{
				Plugins.callMethod(PluginClasses.ANALYTICS, PluginMethods.INITIALIZE, 
									{ display:ap.contentLayer, accountId:ap.googleAnalyticsAccount, debug:DEBUG } );
				Plugins.callMethod(PluginClasses.ANALYTICS, PluginMethods.TRACK_PAGE_VIEW, 
									{ page:ap.appName + " " + ap.version + " started." } );
				
			}
			if (_splashEmbedClassName)
				StageRef.stage.removeChild((StageRef.stage.getChildByName("splash")));
	
			StageRef.stage.addEventListener(UIEvent.MENU_SELECTION, onMenuSelection);	
			StageRef.stage.addEventListener(Event.RESIZE, onStageResize);
			MasterClock.registerCallback(checkOrientation, true, 500);	
			arrangeUI();
			if (ap.loadingSequenceName)
			{
				_loadingSequence = new Sequence();
				_loadingSequence.play(ap.loadingSequenceName, this, menuCall, loadFirstPage);
			}
			else
				loadFirstPage();
		}		
	}
}