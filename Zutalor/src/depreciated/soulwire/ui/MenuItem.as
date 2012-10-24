/**
 * ...
 * @author Justin Windle [www.soulwire.co.uk]
 * @version 0.1
 */

package com.soulwire.g94menu 
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	public class MenuItem extends MovieClip
	{
		
		//- PRIVATE VARIABLES -------------------------------------------------------------------------------------
		
		// Variable                    // Data Type
		
		private var _id:               int;
		private var _txt:              String;
		private var _func:             Function;
		private var _params:           Object;
		
		//- PUBLIC VARIABLES --------------------------------------------------------------------------------------
		
		// Variable                    // Data Type
		
		//- CONSTRUCTOR	-------------------------------------------------------------------------------------------
		
		public function MenuItem(txt:String, func:Function = null, params:Object = null) 
		{
			_txt = txt;
			_func = func;
			_params = params;
		}
		
		//- PRIVATE METHODS ---------------------------------------------------------------------------------------
		
		private function onRollOver(e:MouseEvent):void
		{
			bg.alpha = 1;
		}
		
		private function onRollOut(e:MouseEvent):void
		{
			bg.alpha = .6;
		}
		
		//- PUBLIC METHODS ----------------------------------------------------------------------------------------
		
		public function init(id:int, vis:Boolean):void
		{
			_id = id;
			label.text = _txt;
			alpha = Number(vis);
			
			if(_func != null)
			{
				buttonMode = true;
				label.mouseEnabled = false;
				addEventListener(MouseEvent.ROLL_OVER, onRollOver);
				addEventListener(MouseEvent.ROLL_OUT, onRollOut);
				addEventListener(MouseEvent.CLICK, _func);
				onRollOut(null);
			}
		}
		
		//- EVENT HANDLERS ----------------------------------------------------------------------------------------
		
		//- GETTERS & SETTERS -------------------------------------------------------------------------------------
		
		public function get id():int
		{
			return _id;
		}
		
		public function get params():Object
		{
			return _params;
		}
		
		//- HELPERS -----------------------------------------------------------------------------------------------
		
		//- END CLASS ---------------------------------------------------------------------------------------------
		
	}
	
}
