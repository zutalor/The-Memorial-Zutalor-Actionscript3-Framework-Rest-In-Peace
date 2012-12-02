package com.zutalor.components.text 
{
	import com.zutalor.components.Component;
	import com.zutalor.components.interfaces.IComponent;
		import com.zutalor.view.properties.ViewItemProperties;
	import com.zutalor.propertyManagers.PropertyManager;
	import com.zutalor.utils.ShowError;
	import flash.text.TextField;
	/**
	 * ...
	 * @author Geoff
	 */
	public class Text extends Component implements IComponent 
	{		
		protected var textField:TextField;
		
		private static var _textAttributes:PropertyManager;
		private static var _textFormats:PropertyManager;
		private var _tap:TextAttributeProperties;
		
		public function Text(name:String)
		{
			super(name);
		}
		
		public static function register(textAttributes:XMLList, textFormats:XMLList):void
		{	
			if (!_textAttributes)
			{
				_textAttributes = new PropertyManager(TextAttributeProperties);
				_textFormats = new PropertyManager(TextFormatProperties);
			}
			_textAttributes.parseXML(textAttributes);
			_textFormats.parseXML(textFormats);
		}
		
		override public function render(viewItemProperties:ViewItemProperties = null):void
		{
			super.render(viewItemProperties);
			editable = true;
			textField = new TextField();
			if (vip.text)
			{
				textField.text = vip.text;
				if (!textField.text)
					textField.text = ""
				if (vip.textAttributes)
					textAttributes = vip.textAttributes;
			}
			addChild(textField);
		}
		
		public function set textAttributes(preset:String):void
		{
			_tap = _textAttributes.getPropsByName(preset);
			if (_tap)
				applyTextAttributes();
		}

		
		override public function set width(w:Number):void
		{
			textField.width = w;
		}
		
		override public function set height(h:Number):void
		{
			textField.height = h;
		}
		
		override public function set value(value:*):void
		{
			super.value = textField.text;
			textField.text = value.split("\\n").join("\n");
			applyTextAttributes();
		}
		
		// PRIVATE METHODS
				
		private function applyTextAttributes():void
		{
			textField.selectable = _tap.selectable;
			textField.type = _tap.type;
			textField.autoSize = _tap.autoSize;
			textField.antiAliasType = _tap.antiAliasType;
			textField.multiline = _tap.multiline;
			textField.wordWrap = _tap.wordWrap;
			textField.embedFonts = true;
			if (_tap.maxChars)
				textField.maxChars = _tap.maxChars;
			
			if (_tap.textformat)
				textField.setTextFormat(_textFormats.getPropsByName(_tap.textformat).textFormat);
			else
				ShowError.fail(Text,"Missing textformat for textAttributes: " + _tap.name);
		}
	}
}