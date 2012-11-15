﻿package com.zutalor.application
{
	import com.asual.swfaddress.SWFAddress;
	import com.asual.swfaddress.SWFAddressEvent;
	import com.greensock.TweenMax;
	import com.zutalor.air.AirStatus;
	import com.zutalor.amfphp.Remoting;
	import com.zutalor.containers.ViewContainer;
	import com.zutalor.events.AppEvent;
	import com.zutalor.events.UIEvent;
	import com.zutalor.fx.Wind;
	import com.zutalor.motion.MotionUtils;
	import com.zutalor.plugin.constants.PluginClasses;
	import com.zutalor.plugin.constants.PluginMethods;
	import com.zutalor.plugin.Plugins;
	import com.zutalor.properties.ApplicationProperties;
	import com.zutalor.properties.AppStateProperties;
	import com.zutalor.properties.ViewProperties;
	import com.zutalor.propertyManagers.NestedPropsManager;
	import com.zutalor.propertyManagers.Props;
	import com.zutalor.sequence.Sequence;
	import com.zutalor.text.Translate;
	import com.zutalor.ui.Spinner;
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
	import flash.events.StageVideoAvailabilityEvent;
	import flash.media.StageVideoAvailability;
	import flash.net.InterfaceAddress;
	import flash.net.NetworkInfo;
	import flash.net.NetworkInterface;
	import flash.ui.Mouse;
	
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */

	public class AppController extends EventDispatcher
	{	
		private const DEBUG:Boolean =  false;
		
		private const SYSTEM_FONTS:String = "system-fonts";
		private const APP_FONTS:String = "app-fonts";
		private const APP_PRELOAD:String = "app-preload";
		private const SYSTEM_PRELOAD:String = "system-preload";
		
		private var vu:ViewUtils;
		private var mu:MotionUtils;
		
		private var appStateProps:AppStateProperties;
		private var curContainerLoading:String;	
		
		private var ap:ApplicationProperties;
		private var vpm:NestedPropsManager;	
			
		private var _loadingSequence:Sequence;
		private var _curViewProps:ViewProperties;
		private var _firstPage:String;
		private var _appStateCallStack:gDictionary;
		private var _curAppState:String;
		private var _splashEmbedClassName:String;
		private var _bootXmlUrl:String;
		private var _sheild:Sprite;
		private var _initialized:Boolean;
		private var _currentOrientation:String;
		private var _ip:String;

		// CONSTRUCTOR
		
		public function AppController(bootXmlUrl:String,splashClassName:String=null)
		{
			_splashEmbedClassName = splashClassName;
			_bootXmlUrl = bootXmlUrl;
		}
						
		// PUBLIC METHODS
		
		public function init(stage:Stage, ip:String):void
		{	
			if (_initialized)
				return;
				
			_ip = ip;
			StageRef.stage = stage;		
			if (_splashEmbedClassName)
				showSplash();
				
			MasterClock.initialize();
			MasterClock.defaultInterval = 1000 / StageRef.stage.frameRate;
			Props.init(_bootXmlUrl, initialize);
		}
				
		public function closeView(containerName:String, onComplete:Function = null):void
		{
			var appState:String;
			var cc:ViewCloser;
			
			cc = new ViewCloser();
			cc.close(containerName, onComplete);
			appState = vpm.getPropsById(containerName).menuName;
			if (appState)
			{
				_appStateCallStack.deleteByKey(appState);
				appState = _appStateCallStack.getKeyByIndex(_appStateCallStack.length - 1);
				SWFAddress.setTitle(ap.appName + " - " + appState);
				SWFAddress.setValue(appState);	
				_curViewProps = null;
			}
		}	
		
		public function changeAppState(state:String):void 
		{	
			_curAppState = state;
			if (_curViewProps && !_curViewProps.contentPersists)
			{
				if (appStateProps.viewId == _curViewProps.name)
					closeView(_curViewProps.container.name, processStateChange);
				else 
				{
					closeView(_curViewProps.container.name);
					processStateChange();
				}
			}
			else
				processStateChange();
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
			stateChangeSWFAddress(uie.state);
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
			
			if (page || int(page) < Props.pr.appStates.length)
				changeAppState(page);
		}
		
		private function stateChangeSWFAddress(state:String):void 
		{	
			if (state)
			{
				Mouse.show();
				if (!curContainerLoading)
				{
					state = state.toLowerCase();										
					SWFAddress.setTitle(ap.appName + " - " + state);
					SWFAddress.setValue(state);	
					if (ap.googleAnalyticsAccount && AirStatus.isNativeApplication || DEBUG)
						Plugins.callMethod(PluginClasses.ANALYTICS, PluginMethods.TRACK_PAGE_VIEW, 
																				{ page:state } );
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
				changeAppState(_firstPage);
			}
			else
			{
				SWFAddress.setTitle(ap.appName);
				SWFAddress.setValue("");			
			}
			SWFAddress.addEventListener(SWFAddressEvent.CHANGE, onSWFAddressChange);
			dispatchEvent(new AppEvent(AppEvent.INITIALIZED));	
		}	
		
		private function processStateChange():void
		{
			var viewLoader:ViewLoader;
			
			appStateProps = Props.pr.appStates.getPropsByName(_curAppState);

			if (!appStateProps)
			{
				SWFAddress.setTitle(ap.appName);
				SWFAddress.setValue("");			
			}
			else
			{
				dispatchEvent(new AppEvent(AppEvent.STATE_CHANGE));
				if (appStateProps.type == AppStateProperties.SEQUENCE)
				{
						_loadingSequence = new Sequence();
						_loadingSequence.play(appStateProps.sequenceName, this, changeAppState, stateChangeComplete);
				}
				else if (appStateProps.viewId && !_appStateCallStack.getByKey(_curAppState)) 
				{
					_appStateCallStack.insert(_curAppState, appStateProps);
					_curViewProps = vpm.getPropsById(appStateProps.viewId);		
					curContainerLoading = _curViewProps.name;
					viewLoader = new ViewLoader();
					if (appStateProps.transitionPreset)
						_curViewProps.transitionPreset = appStateProps.transitionPreset;
					
					_curViewProps.mediaPreset = appStateProps.mediaPreset;
					viewLoader.load(appStateProps.viewId, appStateProps.name, onAppContainerLoadComplete);							
				}
			}
		}
		
		private function stateChangeComplete():void
		{
			vu.updateContainerScrollPosition(appStateProps.scrollPreset);
			appStateProps = null;
			dispatchEvent(new Event(Event.COMPLETE));
		}
				
		private function onAppContainerLoadComplete():void
		{
			if (curContainerLoading)
			{
				_curViewProps = vpm.getPropsById(curContainerLoading);
				curContainerLoading = "";	
				vu.updateContainerScrollPosition(appStateProps.scrollPreset);
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
			_sheild = new Sprite;
			_sheild.name = "__Sheild";
			setIpAddress();			
			StageRef.stage.addEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, 
																					onStageVideoAbility);	
			SWFAddress.addEventListener(SWFAddressEvent.CHANGE, onSWFAddressFirstBroadcast);			
			MasterClock.initialize();
			Remoting.gateway = ap.gateway;
			_appStateCallStack = new gDictionary();	
			ap.contentLayer = new ViewContainer("contentLayer", ap.designWidth, ap.designHeight);
			
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
				_loadingSequence.play(ap.loadingSequenceName, this, changeAppState, loadFirstPage);
			}
			else
				loadFirstPage();
				
			function setIpAddress():void
			{
				if (!AirStatus.isNativeApplication)
					ap.ip = _ip; // can be passed into the app through flash vars & php.
				else
				{
					var netInterfaces:Vector.<NetworkInterface> = NetworkInfo.networkInfo.findInterfaces();
					var addresses:Vector.<InterfaceAddress> = netInterfaces[0].addresses;
					ap.ip = addresses[0].address;
				}
			}
		}		
	}
}