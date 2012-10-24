<?php
/**
 * Vo Object for Media (Attachments) from Wordpress Database.
 *
 * @package flashpress.vo
 * @author Dale Sattler
 **/
  
  
class WpAttachmentVO extends WpPostVOBase {
	
  	 // The corresponding ActionScript Value Object
 	 //the package path of the ActionScript Object must be in here
	  var $_explicitType = "flashpress.vo.WpAttachmentVO";
	  
	  public $permalink = "";
	  public $media_url = "";
}
?>