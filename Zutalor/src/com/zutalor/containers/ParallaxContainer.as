package com.zutalor.containers 
{
	import com.zutalor.containers.base.ContainerObject;
	import com.zutalor.containers.scrolling.ScrollingContainer;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ParallaxContainer extends ScrollingContainer
	{	
		private var _layers:Vector.<Container>;
		
		public function ParallaxContainer(containerName:String, numLayers:int = 5)
		{
			super(containerName);
			init(numLayers);
		}	
			
		protected function init(numLayers:int):void
		{
			_layers = new Vector.<Container>();
			for (var i:int = 0; i < numLayers; i++)
				_layers.push(new Container(String(i)));
		}
		
		override public function push(child:ContainerObject, options:Object = null):void
		{	
			var c:Container;
				
			if (options) 
			{
				if (options.x < 1 && options.x > 0)
					child.x = width * options.x;
				else
					child.x = x;
				
				if (options.y < 1 && options.y > 0)
					child.y = width * options.y;
				else
					child.y = x;
				
				if (options.layerNum == 0)
					super.push(child);
				else
					_layers[options.layerNum].push(child);
			}
			else
				super.push(child);
		}
	}
}