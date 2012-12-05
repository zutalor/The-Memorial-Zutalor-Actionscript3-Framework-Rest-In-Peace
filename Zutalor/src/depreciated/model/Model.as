package depreciated.model 
{
	import com.zutalor.cache.Cache;
	import com.zutalor.preloading.Asset;
	import com.zutalor.preloading.AssetManager;
	import com.zutalor.properties.TextFormatProperties;
	import com.zutalor.propertyManagers.Props;
	import com.zutalor.utils.Assertions;
	import com.zutalor.utils.Resources;
	import com.zutalor.utils.Singleton;
	import com.zutalor.text.StringUtils;
	import com.zutalor.utils.XMLLoader;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.text.Font;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;
	import flash.ui.ContextMenu;
	import flash.utils.Dictionary;


	/**
	 * The Model class contains shortcuts for parsing a model xml file.
	 * 
	 * @example Example model XML file:
	 * <listing>	
	 * &lt;?xml version="1.0" encoding="utf-8"?&gt;
	 * &lt;model&gt;
	 * 	  &lt;content&gt;
	 *        &lt;text id="helloWorldExample"&gt;&lt;![CDATA[Hello]]&gt;&lt;/text&gt;
	 *        &lt;text id="sparsley"&gt;&lt;![CDATA[Some more example content]]&gt;&lt;/text&gt;
	 *    &lt;/content&gt;
	 *    &lt;properties&gt;
	 *        &lt;propset id="test"&gt;
	 *            &lt;textFormat id="theTextFormat" /&gt;
	 *            &lt;alpha&gt;0.5&lt;/alpha&gt;
	 *            &lt;xywh x="20" y="+30" width="+100" height="100" /&gt; &lt;!-- optional node for x/y/w/h --&gt;
	 *            &lt;y&gt;+30&lt;/y&gt;
	 *            &lt;width&gt;400&lt;/width&gt;
	 *            &lt;alpha&gt;+.4&lt;/alpha&gt;
	 *        &lt;/propset&gt;
	 *        &lt;propset id="tfieldTest"&gt;
	 *            &lt;styleSheet id="colors3" /&gt;
	 *            &lt;htmlText&gt;&lt;![CDATA[&lt;p&gt;&lt;span class="pink"&gt;hello&lt;/span&gt; &lt;span class="some"&gt;w&lt;/span&gt;orld&lt;/p&gt;]]&gt;&lt;/htmlText&gt;
	 *            &lt;htmlText id="sparsley"/&gt; &lt;!-- optionally you can target a content/text node from the model, but not both. --&gt;
	 *        &lt;/propset&gt;
	 *    &lt;/properties&gt;
	 *    &lt;fonts&gt;
	 *        &lt;font libraryName="Arial_Test" inSWF="fonts" /&gt;
	 *        &lt;group id="myGroup"&gt;
	 *            &lt;font libraryName="Helvetica Neueu Bold Condensed" /&gt;
	 *        &lt;/group&gt;
	 *    &lt;/fonts&gt;
	 *    &lt;assets&gt;
	 *        &lt;asset libraryName="clayBanner1" source="clay_banners_1.jpg" preload="true" /&gt;
	 *        &lt;asset libraryName="clayBanner2" source="clay_banners_2.jpg" /&gt;
	 *        &lt;asset libraryName="clayWebpage" source="clay_webpage.jpg" /&gt;
	 *        &lt;group id="sounds"&gt;
	 *            &lt;asset libraryName="thesound" source="sound.mp3" path="sounds" /&gt;
	 *        &lt;/group&gt;
	 *    &lt;/assets&gt;
	 *    &lt;links&gt;
	 *        &lt;link id="google" url="http://www.google.com" /&gt;
	 *        &lt;link id="rubyamf" url="http://www.rubyamf.org" /&gt;
	 *        &lt;link id="guttershark" url="http://www.guttershark.net" window="_blank" /&gt;
	 *    &lt/links&gt;
	 *    &lt;attributes&gt;
	 *        &lt;attribute id="someAttribute" value="the value" /&gt;
	 *    &lt;/attributes&gt;
	 *    &lt;services&gt;
	 *        &lt;gateway id="amfphp" path="amfphp" url="http://localhost/amfphp/gateway.php" objectEncoding="3" /&gt;
	 *        &lt;service id="test" gateway="amfphp" endpoint="Test" limiter="true" attempts="4" timeout="1000" /&gt;
	 *        &lt;service id="foo" url="http://localhost/" attempts="4" timeout="1000" /&gt;
	 *        &lt;service id="sessionDestroy" path="sessiondestroy" url="http://tagsf/services/codeigniter/session/destroy" attempts="4" timeout="1000" responseFormat="variables" /&gt;
	 *        &lt;service id="ci" url="http://tagsf/services/codeigniter/" attempts="4" timeout="1000" responseFormat="variables" /&gt;
	 *        &lt;wsdl id="myWSDL" endpoint="http://example.com/?wsdl" attempts="3" timeout="3000" /&gt;
	 *        &lt;service id="myWSDL" wsdl="myWSDL" /&gt;
	 *    &lt;/services&gt;
	 *    &lt;stylesheets&gt;
	 *        &lt;stylesheet id="colors"&gt;
	 *        &lt;![CDATA[
	 *            .pink{color:#FF0066}
	 *        ]]&gt;
	 *        &lt;/stylesheet&gt;
	 *        &lt;stylesheet id="colors2"&gt;
	 *        &lt;![CDATA[
	 *            .some{color:#FF8548}
	 *        ]]&gt;
	 *        &lt;/stylesheet&gt;
	 *        &lt;stylesheet id="colors3" mergeStyleSheets="colors,colors2" /&gt;
	 *    &lt;/stylesheets&gt;
	 *    &lt;textformats&gt;
	 *        &lt;textformat id="theTF" font="Arial" color="0xFF0066" bold="true" /&gt;
	 *    &lt;/textformats&gt;
	 *    &lt;contextmenus&gt;
	 *        &lt;menu id="menu1"&gt;
	 *            &lt;item id="home" label="home" /&gt;
	 *            &lt;item id="back" label="GO BACK" sep="true"/&gt;
	 *        &lt;/menu&gt;
	 *    &lt;/contextmenus&gt;
	 * &lt;/model&gt;
	 * </listing>
	 * 
	 * <script src="http://mint.codeendeavor.com/?js" type="text/javascript"></script>
	 */
	final public dynamic class Model
	{
		
		protected static var inst:Model;
		private var _model:XML;		
		protected var assets:XMLList;
		protected var stylesheets:XMLList;
		protected var textformats:XMLList;
		protected var fonts:XMLList;
		private var ast:Assertions;
		private var paths:Dictionary;
		private var modelcache:Cache;
				
		private var customStyles:Dictionary;
		private var xmlLoader:XMLLoader;
		private var xmlLoaderOnComplete:Function;
		private var am:AssetManager;
		private static var models:Dictionary;

		public function Model()
		{
			Singleton.assertSingle(Model);
			paths=new Dictionary();
			customStyles=new Dictionary();
			ast=Assertions.gi();
			modelcache=new Cache();
			am=AssetManager.gi();
		}

		public static function gi(which:String='default'):Model
		{
			if(!models)models=new Dictionary();
			if(!models[which])
			{
				var instance:Model=new Model();
				models[which]=instance;
			}
			return models[which];
		}
		
		public function set xml(xml:XML):void
		{
			ast.notNil(xml, "Parameter xml cannot be null");
			_model=xml;
			if(_model.assets)assets=_model.assets;
			if(_model.stylesheets)stylesheets=_model.stylesheets;
			if(_model.textformats)textformats=_model.textformats;
			if(_model.fonts)fonts=_model.fonts;
		}
		
		public function get xml():XML
		{
			return _model;
		}
		
		/**
		 * Load's an xml file to use as the model xml.
		 * Generally this is not needed, unless you use
		 * the model without a DocumentController.
		 * 
		 * @param xmlRequest The xml file to load.
		 * @param onCompleteCallback A callback function for on complete of the xml load.
		 */
		public function loadModelXML(xmlRequest:URLRequest,onCompleteCallback:Function=null):void
		{
			xmlLoaderOnComplete=onCompleteCallback;
			xmlLoader=new XMLLoader();
			xmlLoader.contentLoader.addEventListener(Event.COMPLETE,onXMLComplete,false,0,true);
			xmlLoader.load(xmlRequest);
		}
		
		/**
		 * On model xml complete.
		 */
		private function onXMLComplete(e:Event):void
		{
			xml=xmlLoader.data;
			xmlLoader.removeEventListener(Event.COMPLETE,onXMLComplete);
			if(xmlLoaderOnComplete!=null)xmlLoaderOnComplete();
		}

		public function getAssetByLibraryName(libraryName:String, prependSourcePath:String=null):Asset
		{			
			checkForXML();
			var asset:Asset;
			var cacheKey:String="asset_"+libraryName;
			if (modelcache.isCached(cacheKey)) {
				asset = modelcache.getCachedObject(cacheKey);
				return asset;
			}
			
			ast.notNil(libraryName,"Parameter libraryName cannot be null");
			var node:XMLList=assets..asset.(@libraryName==libraryName);
			var ft:String=(node.@forceType!=undefined&&node.@forceType!="")?node.@forceType:null;
			var src:String=node.@source || node.@src;
			if(prependSourcePath)src=prependSourcePath+src;
			if (node.@path != undefined) src = getPath(node.@path.toString()) + src;
			
			
			var a:Asset=new Asset(src,libraryName,ft);
			modelcache.cacheObject(cacheKey, a);
			return a;
		}
		
		public function getAssetsByLibraryNames(...libraryNames:Array):Array
		{
			checkForXML();
			var cacheKey:String="assets_"+libraryNames.join("");
			if (modelcache.isCached(cacheKey)) {
				return modelcache.getCachedObject(cacheKey) as Array;
			}
			
			var p:Array=[];
			var i:int=0;
			var l:int=libraryNames.length;
			for(i;i<l;i++) p[i]=getAssetByLibraryName(libraryNames[i]);
			modelcache.cacheObject(cacheKey,p);
			return p;
		}
		
		public function getBitmapGroup(groupId:String):Array
		{
			checkForXML();
			var cacheKey:String = "BitmapGroup_" + groupId; 
			
			if (modelcache.isCached(cacheKey)) 
			{
				return modelcache.getCachedObject(cacheKey) as Array;
			}
			else
			{
				var x:XMLList=assets..group.(@id==groupId);
				var n:XML;
				var payload:Array=[];
				for each(n in x..asset)payload.push(getAssetByLibraryName(n.@libraryName));
				modelcache.cacheObject(cacheKey,payload);
				return payload;
			}
		}
		
		public function getAssetsForPreload():Array
		{
			checkForXML();
			var a:XMLList=assets..asset;
			if(!a)
			{
				trace("WARNING: No assets were defined, not doing anything.");
				return null;
			}
			var payload:Array=[];
			for each(var n:XML in a)
			{
				if(n.@preload==undefined||n.@preload=="false")continue;
				var src:String=n.@source||n.@src;
				if(n.attribute("path")!=undefined)src=getPath(n.@path.toString())+src;
				var ast:Asset=new Asset(src,n.@libraryName);
				payload.push(ast);
			}
			return payload;
		}
		
		protected function checkForXML():void
		{
			ast.notNil(_model, "The model xml must be set on the model before attempting to read a property from it. Please see documentation in the DocumentController for the flashvars.model and flashvars.autoInitModel property.",Error);
		}
		
		/**
		 * Get's a piece of content from the content node in xml.
		 * 
		 * @param id The text id.
		 */
		/**
		 * Dispose of the internal cache. The internal cache
		 * caches textformats and stylesheets.
		 */
		public function disposeCache():void
		{
			modelcache.purgeAll();
		}
	}
}