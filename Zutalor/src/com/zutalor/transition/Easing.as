package com.zutalor.transition 
{
	import com.greensock.easing.Back;
	import com.greensock.easing.Bounce;
	import com.greensock.easing.Circ;
	import com.greensock.easing.Cubic;
	import com.greensock.easing.Elastic;
	import com.greensock.easing.Expo;
	import com.greensock.easing.Linear;
	import com.greensock.easing.Quad;
	import com.greensock.easing.Quart;
	import com.greensock.easing.Quint;
	import com.greensock.easing.Sine;

	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Easing
	{
		
		public function Easing() 
		{
			
		}

		public static function getEase(easeName:String):Function
		{
			var ease:Function;
			
			switch (easeName)
			{
				case "backout" :
					ease = Back.easeIn;
					break;
				case "backin" :
					ease = Back.easeOut
					break;
				case "backinout" :
					ease = Back.easeInOut;
					break;
				case "bouncein" :
					ease = Bounce.easeIn;
					break;
				case "bounceout" :
					ease = Bounce.easeOut;
					break;
				case "bounceinout" :
					ease = Bounce.easeInOut;
					break;
				case "circin" :
					ease = Circ.easeIn;
					break;
				case "circout" :
					ease = Circ.easeOut;
					break;
				case "circinout" :
					ease = Circ.easeInOut;
					break;
				case "cubicin" :
					ease = Cubic.easeIn;
					break;
				case "cubicout" :
					ease = Cubic.easeInOut;
					break;
				case "cubicinout" :
					ease = Cubic.easeInOut;
					break;
				case "elasticin" :
					ease = Elastic.easeIn;
					break;
				case "elasticout" :
					ease = Elastic.easeOut;
					break;
				case "elasticinout" :
					ease = Elastic.easeInOut;
					break;
				case "expoin" :
					ease = Expo.easeIn;
					break;
				case "expoout" :
					ease = Expo.easeOut;
					break;
				case "expoinout" :
					ease = Expo.easeInOut;
					break;
				case "linear" :
					ease = Linear.easeNone;
					break;
				case "quadin" :
					ease = Quad.easeIn;
					break;
				case "quadout" :
					ease = Quad.easeOut;
					break;
				case "quadinout" :
					ease = Quad.easeInOut;
					break;
				case "quartin" :
					ease = Quart.easeIn;
					break;
				case "quartout" :
					ease = Quart.easeInOut;
					break;
				case "quartinout" :
					ease = Quart.easeInOut;
					break;
				case "quintin" :
					ease = Quint.easeIn;
					break;
				case "quintout" :
					ease = Quint.easeOut;
					break;
				case "quintinout" :
					ease = Quint.easeInOut;
					break;
				case "sinein" :
					ease = Sine.easeIn;
					break;
				case "sineout" :
					ease = Sine.easeOut;
					break;
				case "sineinout" :
					ease = Sine.easeInOut;
					break;
				default :
					ease = Quart.easeInOut;
			}
			return ease;	
		}
	}
}