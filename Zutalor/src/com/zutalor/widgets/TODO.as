package com.zutalor.widgets 
{
	/**
	 * ...
	 * @author Geoff
	 */
	public class TODO
	{
		
		public function TODO() 
		{
			
		}
		
	}

}


	private function makeNewRipple():void
		{
			_gRippler = new gRippler(_d, _rp.strength * Scale.curAppScale, _rp.scaleX * Scale.curAppScale, _rp.scaleY, _rp.fadeTime);
		}
		
		private function onMouseDown(me:MouseEvent):void
		{
			StageRef.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
			
		}		
		
		private function onMouseMove(me:MouseEvent):void
		{
			StageRef.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
			_gRippler.render(_d.mouseX,_d.mouseY, 20 * Scale.curAppScale, .5);
		}
		
		private function onMouseUp(me:MouseEvent):void
		{
			StageRef.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		private function onResize(e:Event):void
		{
			_gRippler.dispose();
			makeNewRipple();
		}
		
	
						break;
					case REFLECTION_PRESET :
						break; //fix this
						var r:Reflection = new Reflection(d);
						StageRef.stage.addChild(r);
						break;
					case LIQUIFY_PRESET :
						var l:Liquify = new Liquify(d);
						break;
				}
			}
		}
		
		private function makeNewRipple():void
		{
			_gRippler = new gRippler(_d, _rp.strength * Scale.curAppScale, _rp.scaleX * Scale.curAppScale, _rp.scaleY, _rp.fadeTime);
		}
		
		private function onMouseDown(me:MouseEvent):void
		{
			StageRef.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
			
		}		
		
		private function onMouseMove(me:MouseEvent):void
		{
			StageRef.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
			_gRippler.render(_d.mouseX,_d.mouseY, 20 * Scale.curAppScale, .5);
		}
		
		private function onMouseUp(me:MouseEvent):void
		{
			StageRef.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		private function onResize(e:Event):void
		{
			_gRippler.dispose();
			makeNewRipple();
		}	
		
	if (_rp)
			{
				StageRef.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);						
				StageRef.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);						
				StageRef.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);						
				StageRef.stage.removeEventListener(Event.RESIZE, onResize);
				_gRippler.dispose();
				_gRippler = null;
			}				