<?php
/**
 * Vo Object for Comments from Wordpress Database.
 *
 * @package flashpress.vo
 * @author Dale Sattler
 **/
class WpCommentVO {

  // The corresponding ActionScript Value Object
  //the package path of the ActionScript Object must be in here
  var $_explicitType = "flashpress.vo.WpCommentVO";

  // CLASS VARIABLES 
  public $comment_ID = 0; 
  public $comment_post_ID = 0;
  public $comment_author = "";
  public $comment_author_email = "";
  public $comment_author_url = "";
  public $comment_author_IP = "";
  public $comment_date = "";
  public $comment_date_gmt = "";
  public $comment_content = "";
  public $comment_karma = 0;
  public $comment_approved = 0;
  public $comment_agent = "";
  public $comment_type = "";
  public $comment_parent = 0;
  public $user_id = 0;

}
?>