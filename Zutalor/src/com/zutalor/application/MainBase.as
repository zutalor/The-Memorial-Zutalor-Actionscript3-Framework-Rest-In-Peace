package com.zutalor.application
{
	import com.zutalor.air.AirPlugin;
	import com.zutalor.analytics.Analytics;
	import com.zutalor.application.Application;
	import com.zutalor.color.Color;
	import com.zutalor.components.button.Button;
	import com.zutalor.components.graphic.Graphic;
	import com.zutalor.components.group.ComponentGroup;
	import com.zutalor.components.html.StyleSheets;
	import com.zutalor.components.list.List;
	import com.zutalor.components.media.base.MediaPlayer;
	import com.zutalor.components.media.playlist.Playlist;
	import com.zutalor.components.slider.Slider;
	import com.zutalor.components.stepper.Stepper;
	import com.zutalor.components.text.Text;
	import com.zutalor.components.toggle.Toggle;
	import com.zutalor.filters.base.FuzzyFilter;
	import com.zutalor.filters.Filters;
	import com.zutalor.path.Path;
	import com.zutalor.plugin.Plugins;
	import com.zutalor.properties.Properties;
	import com.zutalor.sequence.Sequence;
	import com.zutalor.transition.Transition;
	import com.zutalor.translate.Translate;
	import com.zutalor.view.controller.ViewController;
	import flash.utils.getTimer;

	/**
	 * ...
	 * @author Geoff Pepos
	 */
	
	public class MainBase extends Application
	{
		public var bootXMLUrl:String;
		public var inlineXML:XML;
		public var splashClassName:String;
		public var loadingSoundClassName:String;
		
		private var date:Date;
		
		public function MainBase() { }
				
		protected function initialize():void
		{
			Properties.register(Path, "paths");
			Properties.register(Application, "appSettings");
			Properties.register(AppController, "appStates");
			Properties.register(Translate, "translations");
			Properties.register(ViewController, "views", "view");
			Properties.register(Sequence, "sequences", "sequence");
			Properties.register(Graphic, "graphicStylePresets", null, Graphic.registerStylePresets);
			Properties.register(Graphic, "graphics", "graphic", Graphic.registerGraphicPresets);
			Properties.register(Filters, "filters", "filter");
			Properties.register(Transition, "transitionPresets");
			Properties.register(Button, "buttonPresets");
			Properties.register(Toggle, "togglePresets");
			Properties.register(Stepper, "stepperPresets");
			Properties.register(Slider, "sliderPresets");
			Properties.register(ComponentGroup, "componentGroupPresets");
			Properties.register(Text, "textAttributePresets", null, Text.registerTextAttributes);
			Properties.register(Text, "textFormatPresets", null, Text.registerTextFormats);
			Properties.register(StyleSheets, "cssPresets");
			Properties.register(MediaPlayer, "mediaPresets");
			Properties.register(Playlist, "playlists" , "playlist");
			Properties.register(List, "listPresets");
			Properties.register(Color, "colors", "color");
			Properties.register(Filters, "filters", "filter");
			Properties.register(FuzzyFilter, "glowPresets");
			Properties.register(FuzzyFilter, "shadowPresets");
			
			if (bootXMLUrl)
			{
				date = new Date();
				bootXMLUrl += "?t=" + date.getTime();
			}
			super.start(bootXMLUrl, inlineXML, splashClassName, loadingSoundClassName);
		}
	}
}