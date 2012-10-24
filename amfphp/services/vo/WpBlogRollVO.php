<?php
/**
 * Vo Object for BlogRoll from Wordpress Database.
 *
 * @package flashpress.vo
 * @author Dale Sattler
 **/
class WpBlogRollVO {

  // The corresponding ActionScript Value Object
  //the package path of the ActionScript Object must be in here
  var $_explicitType = "flashpress.vo.WpBlogRoll";

  // CLASS VARIABLES 
  public $link_id = 0;
  public $link_url = "";
  public $link_name = "";
  public $link_image = "";
  public $link_target = "";
  public $link_category = 0;
  public $link_description = "";
  public $link_visible = "";
  public $link_owner = 0;
  public $link_rating = 0;
  public $link_updated = "";
  public $link_rel = "";
  public $link_notes = "";
  public $link_rss = "";
}
?>