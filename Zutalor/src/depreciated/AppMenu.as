package depreciated
{
	import com.zutalor.properties.MenuProperties;
	import com.zutalor.ui.Menu;
	import com.zutalor.utils.HotKeyManager;
	import flash.display.Sprite;
	import flash.display.Stage;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class AppMenu extends Sprite
	{
		private var _width:int;
		private var _height:int;
		private var _leading:int;
		private var _containerName:String;
		private var _autoArrange:String;
		
		private var _hPos:String;
		private var _vPos:String;
		private var _vPad:int;
		private var _hPad:int;
		private var _resizeMode:String;
		private var _isVisible:Boolean;
		private var _menu:Menu;
		private var _menuProperties:Array;
		private var _index:Array;
		private var _xl:XMLList;
		
		private var hkm:HotKeyManager;		
		private var _stageRef:Stage;
		
		public function AppMenu(xl:XMLList, stage:Stage) 
		{
			_stageRef = stage;
			_xl = xl;
			_menuProperties = [];
			_index = [];
			hkm = HotKeyManager.gi();
			parseXML();
			_menu = new Menu(_width, _height, _leading);	
			addChild(_menu);
			populate();
			_menu.contentContainer.autoArrangeContainerChildren( { padding:_leading, arrange:_autoArrange } );
		}
		
		public function get isVisible():Boolean
		{
			return _isVisible;
		}
		
		public function get hPos():String
		{
			return _hPos;
		}
		
		public function get vPos():String
		{
			return _vPos;
		}

		public function get hPad():int
		{
			return _hPad;
		}
		
		public function get vPad():int
		{
			return _vPad;
		}
		
		public function get containerName():String
		{
			return _containerName;
		}
		
		public function get resizeMode():String
		{
			return _resizeMode;
		}
		
		public function getMenuPropsByName(name:String):MenuProperties
		{
			var i:int;
			i = _index.indexOf(name.toLowerCase());
			if (i >= 0)
				return _menuProperties[i] as MenuProperties;
			else
				return null;
		}
		
		public function getMenuPropsByIndex(index:int):MenuProperties
		{
			return _menuProperties[index] as MenuProperties;
		}
		
		public function getNumMenuProps():int
		{
			return _menuProperties.length;
		}
		
		public function menuItemExists(name:String):Boolean
		{
			var i:int;
			
			if (!name)
				return false;
			else
			{
				i = _index.indexOf(name.toLowerCase());
				
				if (i >= 0)
					if (_menuProperties[i].heading)
						return false;
					else	
						return true;
				else
					return false;
			}
		}
				
		private function parseXML():void
		{	
			_width = _xl.@width;
			_height = _xl.@height;
			_leading = _xl.@leading;
			_containerName = _xl.@containerName;
			this.x = _xl.@x;
			this.y = _xl.@y;
			_hPad = _xl.@hPad;
			_vPad = _xl.@vPad;
			_hPos = _xl.@hPos;
			_vPos = _xl.@vPos;
			_resizeMode = _xl.@resizeMode;
			_autoArrange = _xl.@autoArrange;
			if (_xl.@visible == "true")
				_isVisible = true;
			else
				_isVisible = false;
		}
		
		private function populate():void
		{			
			for (var i:int = 0; i < _xl.item.length(); i++)
			{
				var mp:MenuProperties = new MenuProperties();
				mp.parseXML(_xl.item[i]);
					
				if (mp.hotkey)
					hkm.addMapping(_stageRef, mp.hotkey, mp.name);
				
				_index[i] = String(_xl.item[i].@name).toLowerCase();
				_menuProperties[i] = mp;
			}
		}	
	}
}