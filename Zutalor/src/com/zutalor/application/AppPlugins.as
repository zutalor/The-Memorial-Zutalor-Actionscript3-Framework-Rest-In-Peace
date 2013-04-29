package com.zutalor.application
{
	import com.google.analytics.debug.Label;
	import com.zutalor.air.AirPlugin;
	import com.zutalor.air.AirStatus;
	import com.zutalor.analytics.Analytics;
	import com.zutalor.components.button.Button;
	import com.zutalor.components.embed.Embed;
	import com.zutalor.components.graphic.Graphic;
	import com.zutalor.components.group.ComponentGroup;
	import com.zutalor.components.group.RadioGroup;
	import com.zutalor.components.html.Html;
	import com.zutalor.components.list.BasicListItemRenderer;
	import com.zutalor.components.list.List;
	import com.zutalor.components.media.audio.AudioPlayer;
	import com.zutalor.components.media.playlist.Playlist;
	import com.zutalor.components.media.video.VideoPlayer;
	import com.zutalor.components.slider.Slider;
	import com.zutalor.components.stepper.Stepper;
	import com.zutalor.components.text.Text;
	import com.zutalor.components.toggle.Toggle;
	import com.zutalor.components.web.WebBridge;
	import com.zutalor.containers.Container;
	import com.zutalor.containers.ParallaxContainer;
	import com.zutalor.containers.ScrollingContainer;
	import com.zutalor.containers.ViewContainer;
	import com.zutalor.controllers.DialogController;
	import com.zutalor.filters.Glow;
	import com.zutalor.filters.Shadow;
	import com.zutalor.gesture.DoubleTapGesture;
	import com.zutalor.gesture.GestureListener;
	import com.zutalor.plugin.Plugins;
	import org.gestouch.gestures.LongPressGesture;
	import org.gestouch.gestures.PanGesture;
	import org.gestouch.gestures.RotateGesture;
	import org.gestouch.gestures.SwipeGesture;
	import org.gestouch.gestures.TapGesture;
	import org.gestouch.gestures.TransformGesture;
	import org.gestouch.gestures.ZoomGesture;
	
	/**
	 * ...
	 * @author Geoff
	 */
	public class AppPlugins
	{
		
		public function AppPlugins()
		{
			init();
		}
		
		private function init():void
		{
			
			Plugins.registerClassAndCreateCachedInstance(AirPlugin);
			AirStatus.initialize();
			
			GestureListener.register(PanGesture);
			GestureListener.register(SwipeGesture);
			GestureListener.register(DoubleTapGesture);
			GestureListener.register(TapGesture);
			GestureListener.register(LongPressGesture);
			GestureListener.register(RotateGesture);
			GestureListener.register(TransformGesture);
			GestureListener.register(ZoomGesture);
		
			Plugins.registerClassAndCreateCachedInstance(Analytics);
			Plugins.registerClassAndCreateCachedInstance(DialogController);
			Plugins.registerClass(ViewContainer);
			Plugins.registerClass(Container);
			Plugins.registerClass(Text);
			Plugins.registerClass(Label);
			Plugins.registerClass(Embed);
			Plugins.registerClass(Graphic);
			Plugins.registerClass(Shadow);
	
			Plugins.registerClass(ScrollingContainer);
			Plugins.registerClass(ParallaxContainer);
			Plugins.registerClass(Button);
			Plugins.registerClass(Html);
			Plugins.registerClass(Toggle);
			Plugins.registerClass(ComponentGroup);
			Plugins.registerClass(RadioGroup);
			Plugins.registerClass(Slider);
			Plugins.registerClass(Stepper);
			Plugins.registerClass(List);
			Plugins.registerClass(VideoPlayer);
			Plugins.registerClass(AudioPlayer);
			Plugins.registerClass(Playlist);
			Plugins.registerClass(WebBridge);
			Plugins.registerClass(BasicListItemRenderer);
			Plugins.registerClass(Glow);
		}
	}

}