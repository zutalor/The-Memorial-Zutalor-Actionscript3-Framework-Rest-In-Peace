﻿package com.zutalor.application
{
	import com.asual.swfaddress.SWFAddress;
	import com.asual.swfaddress.SWFAddressEvent;
	import com.greensock.TweenMax;
	import com.zutalor.air.AirStatus;
	import com.zutalor.amfphp.Remoting;
	import com.zutalor.color.Color;
	import com.zutalor.events.AppEvent;
	import com.zutalor.events.UIEvent;
	import com.zutalor.plugin.constants.PluginClasses;
	import com.zutalor.plugin.constants.PluginMethods;
	import com.zutalor.plugin.Plugins;
	import com.zutalor.properties.ApplicationProperties;
	import com.zutalor.properties.AppStateProperties;
	import com.zutalor.propertyManagers.NestedPropsManager;
	import com.zutalor.propertyManagers.Props;
	import com.zutalor.sequence.Sequence;
	import com.zutalor.translate.Translate;
	import com.zutalor.utils.gDictionary;
	import com.zutalor.utils.MasterClock;
	import com.zutalor.utils.Resources;
	import com.zutalor.utils.StageRef;
	import com.zutalor.view.controller.ViewController;
	import com.zutalor.view.properties.ViewProperties;
	import com.zutalor.view.rendering.ViewCreator;
	import com.zutalor.view.utils.ViewCloser;
	import com.zutalor.view.utils.ViewUtils;
	import com.zutalor.widgets.Spinner;
	import flash.display.Bitmap;
	import flash.display.StageOrientation;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.StageVideoAvailabilityEvent;
	import flash.media.StageVideoAvailability;
	
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */

	public class AppController extends EventDispatcher
	{	
		private var vu:ViewUtils;
		
		private var appStateProps:AppStateProperties;
		private var curContainerLoading:String;	
		
		private var ap:ApplicationProperties;
		private var vpm:NestedPropsManager;	
			
		private var _loadingSequence:Sequence;
		private var _curViewProps:ViewProperties;
		private var _firstState:String;
		private var _appStateCallStack:gDictionary;
		private var _curAppState:String;
		private var _splashEmbedClassName:String;
		private var _bootXmlUrl:String;
		private var _currentOrientation:String;
		private var _ip:String;

		private const DEBUG_ANALYTICS:Boolean =  false;
		
		public function AppController(bootXmlUrl:String, ip:String, splashClassName:String=null)
		{
			_splashEmbedClassName = splashClassName;
			_ip = ip;
			_bootXmlUrl = bootXmlUrl;
		}
		
		public function initialize():void
		{	
			if (_splashEmbedClassName)
				showSplash();
				
			MasterClock.initialize();
			MasterClock.defaultInterval = 1000 / StageRef.stage.frameRate;
			Props.init(_bootXmlUrl, init);
		}
		
		public function enableAppState(state:String):void 
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
		
		// PRIVATE METHODS		
				
		private function closeView(viewName:String, onComplete:Function = null):void
		{
			var appState:String;
			var cc:ViewCloser;
			
			cc = new ViewCloser();
			cc.close(viewName, onComplete);
			appState = ViewProperties(vpm.getPropsById(viewName)).appState;
			if (appState)
			{
				_appStateCallStack.deleteByKey(appState);
				appState = _appStateCallStack.getKeyByIndex(_appStateCallStack.length - 1);
				SWFAddress.setTitle(ap.appName + " - " + appState);
				SWFAddress.setValue(appState);	
				_curViewProps = null;
			}
		}			

		private function showSplash():void
		{
			var splash:Bitmap;
			splash = Resources.createInstance(_splashEmbedClassName);
			splash.name = "__splash";
			StageRef.stage.addChild(splash);
			splash.x = (StageRef.stage.fullScreenWidth - splash.width) / 2;
			splash.y = (StageRef.stage.fullScreenHeight - splash.height) / 2;
			TweenMax.from(splash, 1, { alpha:0 } );
		}
	
		private function onStageVideoAbility(e:StageVideoAvailabilityEvent):void 
		{ 
			ap.stageVideoAvailable = (e.availability == StageVideoAvailability.AVAILABLE);
		}
		
		private function onStateSelected(uie:UIEvent):void
		{
			stateChangeSWFAddress(uie.state);
		}		
		
		private function onSWFAddressFirstBroadcast(e:SWFAddressEvent):void	
		{
			SWFAddress.removeEventListener(SWFAddressEvent.CHANGE, onSWFAddressFirstBroadcast);	
			_firstState = e.value.toLowerCase();
			
			if (_firstState != "/") 
				_firstState = _firstState.substring(1); 
			else
				_firstState = ap.firstState.toLowerCase();
				
			SWFAddress.setTitle(ap.appName + " - " + _firstState);
		}
		
		private function onSWFAddressChange(e:SWFAddressEvent = null):void	
		{
			var page:String;
	
			page = e.value.toLowerCase();
			if (page != "/")		
				page = page.substring(1);
			
			if (page || int(page) < Props.pr.appStates.length)
				enableAppState(page);
		}
		
		private function stateChangeSWFAddress(state:String):void 
		{	
			if (state && !curContainerLoading)
			{
				state = state.toLowerCase();										
				SWFAddress.setTitle(ap.appName + " - " + state);
				SWFAddress.setValue(state);	
				if (ap.googleAnalyticsAccount && AirStatus.isNativeApplication || DEBUG_ANALYTICS)
					Plugins.callMethod(PluginClasses.ANALYTICS, PluginMethods.TRACK_PAGE_VIEW, 
																			{ page:state } );
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
			if (_firstState)
				enableAppState(_firstState);
			else
			{
				SWFAddress.setTitle(ap.appName);
				SWFAddress.setValue("");			
			}
			SWFAddress.addEventListener(SWFAddressEvent.CHANGE, onSWFAddressChange);
			dispatchEvent(new AppEvent(AppEvent.INITIALIZED));	
			if (_splashEmbedClassName)
				StageRef.stage.removeChild((StageRef.stage.getChildByName("__splash")));
		}	
		
		private function processStateChange():void
		{
			var viewCreator:ViewCreator;
			
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
						_loadingSequence.play(appStateProps.sequenceName, this, stateChangeComplete);
				}
				else if (appStateProps.viewId && !_appStateCallStack.getByKey(_curAppState)) 
				{
					_appStateCallStack.insert(_curAppState, appStateProps);
					_curViewProps = vpm.getPropsById(appStateProps.viewId);		
					curContainerLoading = _curViewProps.name;
					viewCreator = new ViewCreator();
					if (appStateProps.transitionPreset)
						_curViewProps.transitionPreset = appStateProps.transitionPreset;
					
					_curViewProps.mediaPreset = appStateProps.mediaPreset;
					viewCreator.create(appStateProps.viewId, appStateProps.name, onAppContainerLoadComplete);							
				}
			}
		}
		
		private function stateChangeComplete():void
		{
			appStateProps = null;
			dispatchEvent(new Event(Event.COMPLETE));
		}
				
		private function onAppContainerLoadComplete():void
		{
			if (curContainerLoading)
			{
				_curViewProps = vpm.getPropsById(curContainerLoading);
				curContainerLoading = "";	
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		 	
		private function init():void
		{
			ap = ApplicationProperties.gi();
			vu = ViewUtils.gi();
			vpm = ViewController.presets;
			
			ap.ip = _ip;

			StageRef.stage.addEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, 
																					onStageVideoAbility);	
			SWFAddress.addEventListener(SWFAddressEvent.CHANGE, onSWFAddressFirstBroadcast);			
			MasterClock.initialize();
			Remoting.gateway = ap.gateway;
			_appStateCallStack = new gDictionary();	
			Translate.language = Props.ap.language;
			Color.theme = Props.ap.colorTheme;

			if (ap.spinningpresetId)
				Spinner.init(ap.spinningpresetId, ap.spinningGraphicCyclesPerSecond);
			
			if (ap.googleAnalyticsAccount && AirStatus.isNativeApplication || DEBUG_ANALYTICS)
			{
				Plugins.callMethod(PluginClasses.ANALYTICS, PluginMethods.INITIALIZE, 
									{ display:StageRef.stage, accountId:ap.googleAnalyticsAccount, debug:DEBUG_ANALYTICS } );
				Plugins.callMethod(PluginClasses.ANALYTICS, PluginMethods.TRACK_PAGE_VIEW, 
									{ page:ap.appName + " " + ap.version + " started." } );
			}
			
			StageRef.stage.addEventListener(UIEvent.APP_STATE_SELECTED, onStateSelected);	
			StageRef.stage.addEventListener(Event.RESIZE, vu.onStageResize);
			MasterClock.registerCallback(checkOrientation, true, 500);	
			vu.onStageResize();
						
			if (ap.loadingSequenceName)
			{
				_loadingSequence = new Sequence();
				_loadingSequence.play(ap.loadingSequenceName, this, loadFirstPage);
			}
			else
				loadFirstPage();
		}		
	}
}