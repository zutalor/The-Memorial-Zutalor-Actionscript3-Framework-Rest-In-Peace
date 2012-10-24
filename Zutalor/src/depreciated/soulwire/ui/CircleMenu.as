
/**		
 * 
 *	CircleMenu v1.00
 *	06/11/2008 10:10
 * 
 *	© JUSTIN WINDLE | soulwire ltd
 *	http://blog.soulwire.co.uk
 * 
 * This class is licensed under Creative Commons Attribution 3.0 License:  
 * http://creativecommons.org/licenses/by/3.0/
 * 
 * You are free to utilise this class in any manner you see fit, but it is
 * provided ‘as is’ without expressed or implied warranty. The author should
 * be acknowledged and credited appropriately wherever this work is used.
 * 
 **/

package soulwire.ui 
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	import gs.easing.Expo;
	import gs.TweenLite;

	public class CircleMenu extends Sprite
	{
	
		//___________________________________________________________		_____
		//————————————————————————————————————————————— CLASS MEMBERS		VALUE
		
		private static const toDEGREES:					Number				= 180 / Math.PI;
		private static const toRADIANS:					Number				= Math.PI / 180;
		
		//———————————————————————————————————————————————————————————
		
		private var _activeItemScale:					Number				= 1.8;
		private var _minVisibleScale:					Number				= 0.8;
		private var _minVisibleAlpha:					Number				= 0.2;
		
		private var _itemDictionary:					Dictionary;
		private var _innerRadius:						int;
		private var _angleSpacing:						int;
		private var _visibleItems:						int;
		private var _currentIndex:						int;
		private var _maxOffset:							int;
		
		//___________________________________________________________
		//————————————————————————————————————————— GETTERS + SETTERS
		
		/**
		 * The scale factor of the active menu item
		 */
		
		public function get activeItemScale():Number
		{
			return _activeItemScale;
		}
		
		public function set activeItemScale( value:Number ):void
		{
			if ( value < 0 ) value = 0;
			_activeItemScale = value;
			positionItems();
		}
		/**
		 * The minimum scale value for faded but still visible menu items
		 */
		
		public function get minVisibleScale():Number
		{
			return _minVisibleScale;
		}
		
		public function set minVisibleScale( value:Number ):void
		{
			_minVisibleScale = value;
			positionItems();
		}
		
		/**
		 * The minimum alpha value for faded but still visible menu items
		 */
		
		public function get minVisibleAlpha():Number
		{
			return _minVisibleAlpha;
		}
		
		public function set minVisibleAlpha( value:Number ):void
		{
			_minVisibleAlpha = value;
			positionItems();
		}
		
		/**
		 * The index of the currently active menu item
		 */
		
		public function get currentIndex():int
		{
			return _currentIndex;
		}
		
		public function set currentIndex( value:int ):void
		{
			if ( value < 1 ) value = 1;
			if ( value > numChildren ) value = numChildren;
			
			_currentIndex = value;
			positionItems();
		}
		
		/**
		 * The radius of the inner circle, or the space between the
		 * menu centre and the left-most point of a given menu item
		 */
		
		public function get innerRadius():int
		{
			return _innerRadius;
		}
		
		public function set innerRadius( value:int ):void
		{
			if ( value < 0 ) value = -value;
			_innerRadius = value;
			positionItems();
		}
		
		/**
		 * The degree angle of spacing between each visible item
		 */
		
		public function get angleSpacing():int
		{
			return _angleSpacing;
		}
		
		public function set angleSpacing( value:int ):void
		{
			var maxAngle:int = 360 / _visibleItems;
			if ( value >= maxAngle ) value = maxAngle;
			if ( value < 0 ) value = -value;
			_angleSpacing = value;
			positionItems();
		}
		
		/**
		 * The number of items that are visible at any given time
		 * (should be an odd number and will be set to so if even)
		 */
		
		public function get visibleItems():int
		{
			return _visibleItems;
		}
		
		public function set visibleItems( value:int ):void
		{
			if ( value < 2 ) value = 2;
			if ( value / 2 is int ) value += 1;
			
			_visibleItems = value;
			_maxOffset = Math.round( value / 2 );
			positionItems();
		}
		
		//___________________________________________________________
		//——————————————————————————————————————————————— CONSTRUCTOR
		
		/**
		 * Creates a new instance of CircleMenu
		 * 
		 * @param	__innerRadius
		 * 
		 * The radius of the inner circle, or the space between the
		 * menu centre and the left-most point of a given menu item
		 * 
		 * @param	__angleSpacing
		 * 
		 * The degree angle of spacing between each visible item
		 * 
		 * @param	__visibleItems
		 * 
		 * The number of items that are visible at any given time
		 * (should be an odd number and will be set to so if even)
		 */
		
		public function CircleMenu( __innerRadius:int, __angleSpacing:int, __visibleItems:int ) 
		{
			_currentIndex = 1;
			_itemDictionary = new Dictionary();
			
			innerRadius = __innerRadius;
			visibleItems = __visibleItems;
			angleSpacing = __angleSpacing;
		}
		
		//___________________________________________________________
		//——————————————————————————————————————————————————— METHODS
		
		/**
		 * Adds a DisplayObject to the menu to be used as a menu item
		 * 
		 * @param	child
		 * 
		 * The DisplayObject to add to the menu
		 * 
		 * @return
		 * 
		 * The added DisplayObject
		 */
		
		override public function addChild( child:DisplayObject ):DisplayObject 
		{
			child.x = 0;
			child.y = -(child.height / 2);
			
			var holder:Sprite = new Sprite();
			_itemDictionary[ child ] = holder;
			
			super.addChild( holder );
			holder.addChild( child );
			holder.alpha = 0;
			positionItems();
			
			return child;
		}
		
		/**
		 * Adds a DisplayObject to the menu at the specified index
		 * 
		 * @param	child
		 * 
		 * The DisplayObject to add to the menu
		 * 
		 * @param	index
		 * 
		 * The index at which to place the added DisplayObject
		 * 
		 * @return
		 * 
		 * The added DisplayObject
		 */
		
		override public function addChildAt( child:DisplayObject, index:int ):DisplayObject 
		{
			child.x = 0;
			child.y = -(child.height / 2);
			
			var holder:Sprite = new Sprite();
			_itemDictionary[ child ] = holder;
			
			super.addChildAt( holder, index );
			holder.addChild( child );
			holder.alpha = 0;
			positionItems();
			
			return child;
		}
		
		/**
		 * Removed a DisplayObject from the menu
		 * 
		 * @param	child
		 * 
		 * The DisplayObject to remove
		 * 
		 * @return
		 * 
		 * The removed DisplayObject
		 */
		
		override public function removeChild( child:DisplayObject ):DisplayObject 
		{
			super.removeChild( _itemDictionary[ child ] );
			delete _itemDictionary[ child ];
			return child;
		}
		
		/**
		 * Removes the menu item at the specified index
		 * 
		 * @param	index
		 * 
		 * The menu item at this index will be removed
		 * 
		 * @return
		 * 
		 * The removed menu item
		 */
		
		override public function removeChildAt( index:int ):DisplayObject 
		{
			var remove:DisplayObject = getChildAt( index );
			super.removeChildAt( index );
			delete _itemDictionary[ remove ];
			return remove;
		}
		
		/**
		 * Moves the specified DisplayObject to the index provided
		 * 
		 * @param	child
		 * 
		 * The menu item whose index you wish to set
		 * 
		 * @param	index
		 * 
		 * The desired index for the menu item
		 */
		
		override public function setChildIndex( child:DisplayObject, index:int ):void 
		{
			super.setChildIndex( _itemDictionary[ child ], index );
		}
		
		/**
		 * Returns the index of a particular menu item
		 * 
		 * @param	child
		 * 
		 * The menu item whose index you wish to find
		 * 
		 * @return
		 * 
		 * Teh index of the specified menu item
		 */
		
		override public function getChildIndex( child:DisplayObject ):int 
		{
			return super.getChildIndex( _itemDictionary[ child ] );
		}
		
		/**
		 * Scrolls the CircleMenu so that the provided item is centred
		 * 
		 * @param	item
		 * 
		 * The menu item to scroll to
		 */
		
		public function scrollToItem( item:DisplayObject ):void
		{
			scrollToIndex( getChildIndex( item ) + 1 );
		}
		
		/**
		 * Scrolls the CircleMenu so that the item at the provided index is centred
		 * 
		 * @param	index
		 * 
		 * The index to scroll the menu to
		 */
		
		public function scrollToIndex( index:int ):void
		{
			currentIndex = index;
		}
		
		/**
		 * Scrolls the menu to the next item
		 */
		
		public function next():void
		{
			currentIndex++;
		}
		
		/**
		 * Scrolls the menu to the previous item
		 */
		
		public function prev():void
		{
			currentIndex--;
		}
		
		//———————————————————————————————————————————————————————————
		
		private function positionItems():void
		{
			if ( numChildren == 0 ) return;
			
			var maxAngle:Number = _maxOffset * _angleSpacing;
			
			var item:Sprite;
			var hideItem:Boolean;
			var angle:Number;
			var offset:int;
			
			var tX:Number;
			var tY:Number;
			var tS:Number;
			var tR:Number;
			var tA:Number;

			for (var i:int = 0; i < numChildren; i++) 
			{
				offset = (i + 1) - _currentIndex;
				angle = limit(offset * _angleSpacing, -180, 180) * toRADIANS;
				hideItem = Math.abs( offset ) >= _maxOffset;
				
				item = super.getChildAt(i) as Sprite;
				item.mouseChildren = !hideItem;

				tX = _innerRadius * Math.cos( angle );
				tY = _innerRadius * Math.sin( angle );
				tS = offset == 0 ? activeItemScale : 1 - ( Math.abs(offset / (_maxOffset - 1)) * ( 1 - minVisibleScale ) );
				tR = angle * toDEGREES;
				tA = hideItem ? 0 : 1 - ( Math.abs(offset / (_maxOffset - 1)) * ( 1 - minVisibleAlpha ) );
				
				if ( tS < 0 ) tS = 0;
				
				TweenLite.to( item, 0.5, { x:tX, y:tY, rotation:tR, scaleX:tS, scaleY:tS, alpha:tA, ease:Expo.easeOut } );
			}
		}
		
		public static function limit( value:Number, min:Number, max:Number = NaN ):Number
		{
			if ( isNaN( max ) )
			{
				max = min;
				min = 0;
			}
			
			if ( value < min ) value = min;
			if ( value > max ) value = max;
			
			return value;
		}
		
	}
	
}
