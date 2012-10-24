package com.zutalor.utils
{
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class SocialMedia	 
	{
		
	}

	
	public static function shareFacebook(evt:Event = null):void 
	{
		if (ExternalInterface.available) 
		{
			var code:XML = <script>
				<![CDATA[
				function shareFacebook(){
				var d=document
				var f='http://www.facebook.com/share'
				var l=d.location
				var e=encodeURIComponent
				var t=d.title
				var p='.php?src=bm&v=4&i=1277427231&u='+e(l.href)+'&t='+e(t);
				try{if(!/^(.*\.)?facebook\.[^.]*$/.test(l.host))throw(0);share_internal_bookmarklet(p)}catch(z) {a=function() {if (!window.open(f+'r'+p,'sharer','toolbar=0,status=0,resizable=1,width=626,height=436'))l.href=f+p};if (/Firefox/.test(navigator.userAgent))setTimeout(a,0);else{a()}}void(0);
				}
				]]>
			</script>;
		ExternalInterface.call(code);
		}
	}
}