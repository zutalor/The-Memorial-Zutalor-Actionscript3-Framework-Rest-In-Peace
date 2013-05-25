package com.zutalor.application
{
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
	import com.zutalor.utils.StageRef;
	import com.zutalor.view.controller.ViewController;
	import com.zutalor.view.properties.ViewProperties;
	import com.zutalor.view.rendering.ViewCreator;
	import com.zutalor.view.utils.ViewCloser;
	import com.zutalor.view.utils.ViewUtils;
	import com.zutalor.widgets.Spinner;
	import flash.display.Bitmap;
	import flash.display.Stage;
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
		private var _app:Application;
		
		private var ap:ApplicationProperties;
		private var vpm:NestedPropsManager;
			
		private var _loadingSequence:Sequence;
		private var _curViewProps:ViewProperties;
		private var _firstState:String;
		private var _appStateCallStack:gDictionary;
		private var _curAppState:String;
		private var splash:Bitmap;

		private const DEBUG_ANALYTICS:Boolean =  false;
		
		private static var _presets:PropertyManager;
		
		public static function registerPresets(options:Object):void
		{
			if (!_presets)
				_presets = new PropertyManager(AppStateProperties);
			
			_presets.parseXML(options.xml[options.nodeId]);
		}
		
		public function AppController(app:Application)
		{
			_app = app;
			_construct();
		}
		
// PRIVATE METHODS
		
		private function _construct():void
		{
			var samplePlayer:SamplePlayer;

			if (_app.loadingSoundClassName)
			{
				samplePlayer = new SamplePlayer();
				samplePlayer.play(null, EmbeddedResources.getClass(_app.loadingSoundClassName), disposeSamplePlayer);
			}
			
			function disposeSamplePlayer():void
			{
				samplePlayer.dispose();
				samplePlayer = null;
			}

			if (_app.splashEmbedClassNameHD || _app.splashEmbedClassNameSD)
				showSplash();
			
			MasterClock.initialize();
			MasterClock.defaultInterval = 1000 / StageRef.stage.frameRate;
			AppXmlLoader.init(_app.bootXmlUrl, _app.inlineXML, init);
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
			
			if (!_app.splashEmbedClassNameSD)
				_app.splashEmbedClassNameSD = _app.splashEmbedClassNameHD;
			
			if (!_app.splashEmbedClassNameHD)
				_app.splashEmbedClassNameHD = _app.splashEmbedClassNameSD; 
				
			if (StageRef.stage.stageWidth > 320 && _app.splashEmbedClassNameHD)	
				splash = EmbeddedResources.createInstance(_app.splashEmbedClassNameHD);
			else if (_app.splashEmbedClassNameSD)	
				splash = EmbeddedResources.createInstance(_app.splashEmbedClassNameSD);
			
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
					viewCreator.create(appStateProps.viewId, appStateProps.name, onViewContainerLoadComplete);
					viewCreator.container.addEventListener(UIEvent.CLOSE, onCloseView, false, 0, true);
				}
			}
		}
		
		private function stateChangeComplete():void
		{
			appStateProps = null;
			dispatchEvent(new Event(Event.COMPLETE));
		}
				
		private function onViewContainerLoadComplete():void
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
			
			if (_app.ip)
				ap.ip = _app.ip;
				
			if (_app.agent)
				ap.agent = _app.agent;

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
			StyleSheets.loadCss(onInitComplete);
			SWFAddress.addEventListener(SWFAddressEvent.CHANGE, onSWFAddressFirstBroadcast);
		}
		
		private function onInitComplete():void
		{
			if (_app.onInitialized != null)
				_app.onInitialized();
			
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