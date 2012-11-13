package depreciated
{
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author 
	 */
	public class ButtonStates extends Sprite
	{
		public var up:Sprite;
		public var down:Sprite;
		public var over:Sprite;
		public var hit:Sprite;
		public var disabled:Sprite;
		
		public function ButtonStates()
		{		
			up= new Sprite();
			down = new Sprite();
			over = new Sprite();
			hit = new Sprite();	
			disabled = new Sprite();	
		}
	}
	
}