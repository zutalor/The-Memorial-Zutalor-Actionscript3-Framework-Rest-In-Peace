package com.zutalor.application
{
	import com.adobe.utils.IntUtil;
	import com.asual.swfaddress.SWFAddress;
	import com.asual.swfaddress.SWFAddressEvent;
	import com.greensock.TweenMax;
	import com.zutalor.air.AirStatus;
	import com.zutalor.amfphp.Remoting;
	import com.zutalor.application.ApplicationProperties;
	import com.zutalor.audio.SamplePlayer;
	import com.zutalor.color.Color;
	import com.zutalor.components.html.StyleSheets;
	import com.zutalor.events.AppEvent;
	import com.zutalor.events.UIEvent;
	import com.zutalor.plugin.constants.PluginClasses;
	import com.zutalor.plugin.constants.PluginMethods;
	import com.zutalor.plugin.Plugins;
	import com.zutalor.properties.NestedPropsManager;
	import com.zutalor.properties.PropertyManager;
	import com.zutalor.sequence.Sequence;
	import com.zutalor.utils.EmbeddedResources;
	import com.zutalor.utils.gDictionary;
	import com.zutalor.utils.MasterClock;
	import com.zutalor.utils.Scale;
	import com.zutalor.utils.StageRef;
	import com.zutalor.view.controller.ViewController;
	import com.zutalor.view.properties.ViewProperties;
	import com.zutalor.view.rendering.ViewCreator;
	import com.zutalor.view.utils.ViewCloser;
	import com.zutalor.view.utils.ViewUtils;
	import com.zutalor.widgets.RunTimeTrace;
	import com.zutalor.widgets.Spinner;
	import flash.display.Bitmap;
	import flash.display.Stage;
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
		public var vu:ViewUtils;
		
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
		private var _agent:String;
		private var _inlineXML:XML;
		private var splash:Bitmap;
		private var _loadingSoundClassName:String;
		private var _onInitialized:Function;

		private const DEBUG_ANALYTICS:Boolean =  false;
		
		private static var _presets:PropertyManager;
		
		public static function registerPresets(options:Object):void
		{
			if (!_presets)
				_presets = new PropertyManager(AppStateProperties);
			
			_presets.parseXML(options.xml[options.nodeId]);
		}
		
		public function AppController(bootXmlUrl:String, ip:String, agent:String, inlineXML:XML, 
											splashClassName:String, loadingSoundClassName:String, onInitialized:Function)
		{
			_onInitialized = onInitialized;
			_splashEmbedClassName = splashClassName;
			_loadingSoundClassName = loadingSoundClassName;
			_ip = ip;
			_agent = agent;
			_bootXmlUrl = bootXmlUrl;
			_inlineXML = inlineXML;
			initialize();
		}
		
// PRIVATE METHODS
		
		private function initialize():void
		{
			var samplePlayer:SamplePlayer;

			if (_loadingSoundClassName)
			{
				samplePlayer = new SamplePlayer();
				samplePlayer.play(null, EmbeddedResources.getClass(_loadingSoundClassName), disposeSamplePlayer);
			}
			
			function disposeSamplePlayer():void
			{
				samplePlayer.dispose();
				samplePlayer = null;
			}

			if (_splashEmbedClassName)
				showSplash();
			
			MasterClock.initialize();
			MasterClock.defaultInterval = 1000 / StageRef.stage.frameRate;
			AppXmlLoader.init(_bootXmlUrl, _inlineXML, init);
		}

		private function showSplash():void
		{
			var w:int;
			var h:int;
			var stage:Stage;
			
			stage = StageRef.stage;
			if (StageRef.stage.fullScreenSourceRect)
			{
				w = stage.fullScreenSourceRect.width;
				h = stage.fullScreenSourceRect.height;
			}
			else
			{
				w = stage.stageWidth > stage.fullScreenWidth ? stage.fullScreenWidth : stage.stageWidth;
				h = stage.stageHeight > stage.fullScreenHeight ? stage.fullScreenHeight : stage.stageHeight;
			}
			//RunTimeTrace.show(w + " " + h);
			splash = EmbeddedResources.createInstance(_splashEmbedClassName);
			StageRef.stage.addChild(splash);
			splash.x = (w - splash.width) / 2;
			splash.y = (h - splash.height) / 2;
		}
		
		private function onCloseView(e:Event):void
		{
			e.target.removeEventListener(UIEvent.CLOSE, onCloseView);
			closeView(e.target.name);
		}
				
		private function closeView(viewName:String, onComplete:Function = null):void
		{
			var appState:String;
			var vc:ViewCloser;
			
			vc = new ViewCloser();
			vc.close(viewName, onComplete);
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
	
		private function onStageVideoAbility(e:StageVideoAvailabilityEvent):void
		{
			ap.stageVideoAvailable = (e.availability == StageVideoAvailability.AVAILABLE);
		}
		
		private function onStateChangeEvent(uie:UIEvent):void
		{
			changeAppState(uie.state);
		}
		
		private function onSWFAddressFirstBroadcast(e:SWFAddressEvent):void
		{
			SWFAddress.removeEventListener(SWFAddressEvent.CHANGE, onSWFAddressFirstBroadcast);
			_firstState = e.value.toLowerCase();
			
			if (_firstState != "/")
				_firstState = _firstState.substring(1);
			else if (ap.firstState)
				_firstState = ap.firstState.toLowerCase();
				
			SWFAddress.setTitle(ap.appName + " - " + _firstState);
		}
		
		private function onSWFAddressChange(e:SWFAddressEvent):void
		{
			var page:String;
	
			page = e.value.toLowerCase();
			if (page != "/")
				page = page.substring(1);
			
			if (page || int(page) < _presets.length)
				changeAppState(page);
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
				changeAppState(state);
			}
		}
		
		private function changeAppState(state:String):void
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
		
		private function processStateChange():void
		{
			var viewCreator:ViewCreator;
			
			appStateProps = _presets.getPropsByName(_curAppState);

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
					viewCreator.container.addEventListener(UIEvent.CLOSE, onCloseView, false, 0, true);
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
						
			vu = new ViewUtils();

			ap = Application.settings;
			vpm = ViewController.presets;
			
			if (_ip)
				ap.ip = _ip;
				
			if (_agent)
				ap.agent = _agent;

			vu.calcScale();
	
			_appStateCallStack = new gDictionary();

			StageRef.stage.addEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, onStageVideoAbility);
			StageRef.stage.addEventListener(Event.RESIZE, vu.onStageResize);
			MasterClock.initialize();
			Remoting.gateway = ap.gateway;
			Color.theme = ap.colorTheme;

			if (ap.spinnerGraphicId)
				Spinner.init(ap.spinnerGraphicId, ap.spinnerGraphicCyclesPerSecond,
						EmbeddedResources.getClass(ap.spinnerSoundClassName), ap.spinnerSoundInterval);
				
			if (ap.googleAnalyticsAccount && AirStatus.isNativeApplication || DEBUG_ANALYTICS)
			{
				Plugins.callMethod(PluginClasses.ANALYTICS, PluginMethods.INITIALIZE,
									{ display:StageRef.stage, accountId:ap.googleAnalyticsAccount, debug:DEBUG_ANALYTICS } );
				Plugins.callMethod(PluginClasses.ANALYTICS, PluginMethods.TRACK_PAGE_VIEW,
									{ page:ap.appName + " " + ap.version + " started." } );
			}
			
			StageRef.stage.addEventListener(UIEvent.APP_STATE_SELECTED, onStateChangeEvent);
			//MasterClock.registerCallback(checkOrientation, true, 500);
			StyleSheets.loadCss(onInitComplete);
			SWFAddress.addEventListener(SWFAddressEvent.CHANGE, onSWFAddressFirstBroadcast);
		}
		
		private function onInitComplete():void
		{
			if (_onInitialized != null)
				_onInitialized();
				
			if (ap.loadingSequenceName)
			{
				_loadingSequence = new Sequence();
				_loadingSequence.play(ap.loadingSequenceName, this, loadFirstPage);
			}
			else
				loadFirstPage();
		}
		
		private function loadFirstPage():void
		{
			if (_firstState)
				changeAppState(_firstState);
			else
			{
				SWFAddress.setTitle(ap.appName);
				SWFAddress.setValue("");
			}
			SWFAddress.addEventListener(SWFAddressEvent.CHANGE, onSWFAddressChange);

			if (splash)
			{
				TweenMax.to(splash, .1, { alpha:0, onComplete:removeSplash } );
			}
			function removeSplash():void
			{
				StageRef.stage.removeChild(splash);
			}
		}
	}
}