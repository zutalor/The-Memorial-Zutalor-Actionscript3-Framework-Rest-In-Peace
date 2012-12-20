﻿package com.zutalor.application  
{
	import com.zutalor.air.AirPlugin;
	import com.zutalor.analytics.Analytics;
	import com.zutalor.application.Application;
	import com.zutalor.color.Color;
	import com.zutalor.components.button.Button;
	import com.zutalor.components.embed.Embed;
	import com.zutalor.components.graphic.Graphic;
	import com.zutalor.components.group.ComponentGroup;
	import com.zutalor.components.group.RadioGroup;
	import com.zutalor.components.html.Html;
	import com.zutalor.components.html.StyleSheets;
	import com.zutalor.components.label.Label;
	import com.zutalor.components.list.BasicItemRenderer;
	import com.zutalor.components.list.List;
	import com.zutalor.components.media.audio.AudioPlayer;
	import com.zutalor.components.media.base.MediaPlayer;
	import com.zutalor.components.media.playlist.Playlist;
	import com.zutalor.components.media.video.VideoPlayer;
	import com.zutalor.components.slider.Slider;
	import com.zutalor.components.stepper.Stepper;
	import com.zutalor.components.text.Text;
	import com.zutalor.components.toggle.Toggle;
	import com.zutalor.components.web.WebBridge;
	import com.zutalor.filters.Filters;
	import com.zutalor.fx.Transition;
	import com.zutalor.gesture.DoubleTapGesture;
	import com.zutalor.gesture.FlickGesture;
	import com.zutalor.gesture.GestureListener;
	import com.zutalor.path.Path;
	import com.zutalor.plugin.Plugins;
	import com.zutalor.propertyManagers.Properties;
	import com.zutalor.sequence.Sequence;
	import com.zutalor.translate.Translate;
	import com.zutalor.view.controller.ViewController;
	import org.gestouch.gestures.LongPressGesture;
	import org.gestouch.gestures.PanGesture;
	import org.gestouch.gestures.RotateGesture;
	import org.gestouch.gestures.SwipeGesture;
	import org.gestouch.gestures.TapGesture;
	import org.gestouch.gestures.TransformGesture;
	import org.gestouch.gestures.ZoomGesture;

	/**
	 * ...
	 * @author Geoff Pepos
	 */
	
	public class Main extends Application
	{		
		public var bootXMLUrl:String;
		public var splashClassName:String;
		
		public function Main()
		{
			initialize();
		}
				
		protected function initialize():void
		{
			Properties.register(Path, "paths");
			
			Plugins.registerClassAndCreateCachedInstance(AirPlugin);
			Plugins.registerClassAndCreateCachedInstance(SoundScienceUiController);
			Plugins.registerClassAndCreateCachedInstance(Analytics);

			GestureListener.register(PanGesture);
			GestureListener.register(SwipeGesture);
			GestureListener.register(DoubleTapGesture);
			GestureListener.register(TapGesture);
			GestureListener.register(LongPressGesture);
			GestureListener.register(RotateGesture);
			GestureListener.register(TransformGesture);
			GestureListener.register(ZoomGesture);
			GestureListener.register(FlickGesture);
			
			Plugins.registerClass(Button);
			Plugins.registerClass(Html);
			Plugins.registerClass(Toggle);
			Plugins.registerClass(ComponentGroup);
			Plugins.registerClass(RadioGroup);
			Plugins.registerClass(Slider);
			Plugins.registerClass(Stepper);
			Plugins.registerClass(Text);
			Plugins.registerClass(Label);
			Plugins.registerClass(Embed);
			Plugins.registerClass(Graphic);
			Plugins.registerClass(List);
			Plugins.registerClass(VideoPlayer);
			Plugins.registerClass(AudioPlayer);
			Plugins.registerClass(Playlist);
			Plugins.registerClass(WebBridge);
			Plugins.registerClass(BasicItemRenderer);
			
			Properties.register(Application, "appSettings");
			Properties.register(AppController, "appStates");
			Properties.register(ViewController, "views", "view");
			Properties.register(Translate, "translations", "language");
			Properties.register(Sequence, "sequences", "sequence");			
			Properties.register(Graphic, "graphicStylePresets", null, Graphic.registerStylePresets);
			Properties.register(Graphic, "graphics", "graphic", Graphic.registerGraphicPresets);
			Properties.register(Filters, "filters", "filter");
			Properties.register(Transition, "transitionPresets");
			Properties.register(Button, "buttonPresets");
			Properties.register(Toggle, "togglePresets");
			Properties.register(Stepper, "stepperPresets");
			Properties.register(ComponentGroup, "componentGroupPresets");
			Properties.register(Text, "textAttributePresets", null, Text.registerTextAttributes);
			Properties.register(Text, "textFormatPresets", null, Text.registerTextFormats);
			Properties.register(StyleSheets, "cssPresets");
			Properties.register(MediaPlayer, "mediaPresets");
			Properties.register(Playlist, "playlists" , "playlist");
			Properties.register(List, "listPresets");
			Properties.register(Color, "colorThemes", "theme");
			
			super.start(bootXMLUrl, splashClassName);
		}
	}
}