<?php
/**
 * Vo Object for Posts or Pages from Wordpress Database.
 *
 * @package flashpress.vo
 * @author Dale Sattler
 **/
class WpPostVOBase {
	
 //the package path of the ActionScript Object must be in here
  var $_explicitType = "flashpress.vo.WpPostVOBase";

  // CLASS VARIABLES 
  public $ID = 0;
  public $post_author = "";
  public $post_date = "";
  public $post_date_gmt = "";
  public $post_content = "";
  public $post_title = "";
  public $post_category = 0;
  public $post_excerpt = "";
  public $post_status = "";
  public $comment_status = "";
  public $ping_status = "";	
  public $post_password = "";
  public $post_name = "";
  public $to_ping = "";
  public $pinged = "";
  public $post_modified = "";
  public $post_modified_gmt = "";
  public $post_content_filtered = "";
  public $post_parent = 0;
  public $guid = "";
  public $menu_order = 0;
  public $post_type = "";
  public $post_mime_type = "";
  public $comment_count = 0;
  public $ancestors = array();
  public $filter = "";


}
?>