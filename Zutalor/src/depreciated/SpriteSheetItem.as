package depreciated  
{
	import com.zutalor.loaders.AssetManager;
	import com.zutalor.properties.SpriteSheetItemProperties;
	import com.zutalor.properties.SpriteSheetProperties;
	import com.zutalor.propertyManagers.NestedPropsManager;
	import com.zutalor.propertyManagers.Props;
	import com.zutalor.utils.gDictionary;
	import com.zutalor.utils.Logger;
	import com.zutalor.utils.EmbeddedResources;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class SpriteSheetItem
	{
		private static var _bitmapCache:gDictionary;
		private static var _spm:NestedPropsManager;
		private static var _p:Point;
		
		public static function init():void
		{
			_spm = Props.spritesheets;
			_p = new Point();
			_bitmapCache = new gDictionary();
		}
		
		public static function get(spriteSheet:String, spriteSheetItem:String):Bitmap
		{
			var ssi:SpriteSheetItemProperties;
			var ssp:SpriteSheetProperties;
			var bm:Bitmap;
			var rect:Rectangle;
			var index:int;
			var width:int;
			var height:int;
			var a:Bitmap;
			
			try 
			{
				ssp = _spm.getPropsById(spriteSheet);
				ssi = _spm.getItemPropsByName(spriteSheet, spriteSheetItem);
				width = (ssp.itemWidth);
				height = (ssp.itemHeight);
				
				rect = new Rectangle(0, 0, ssp.itemWidth, ssp.itemHeight);
				index = _spm.getItemIndexByName(spriteSheet, spriteSheetItem);
				
				rect.x = ((index % ssp.cols) * width);
				rect.y = (int(index / ssp.cols) * height);
				
				if (ssp.libraryName)
					a = AssetManager.getBitmap(ssp.libraryName);
				else if (ssp.className)
				{
					a = _bitmapCache.getByName(ssp.className);
					if (!a)
					{
						a = EmbeddedResources.createInstance(ssp.className);
						_bitmapCache.addOrReplace(ssp.className, a);
					}
				}
				else
					ShowError.fail(this,"SpriteSheetItem: no className or LibraryName");
					
				bm = new Bitmap(new BitmapData(width, height));
				bm.bitmapData.copyPixels(a.bitmapData, rect, _p);
				
				if (ssi.blendMode)
					bm.blendMode = ssi.blendMode;
					
				bm.smoothing = true;
			}
			catch (errObject:Error)
			{
				ShowError.fail(this,errObject.message);
			}
			
			return bm;
		}
	}
}