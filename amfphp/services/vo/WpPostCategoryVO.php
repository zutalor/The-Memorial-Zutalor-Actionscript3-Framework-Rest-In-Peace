<?php
/**
 * Vo Object for Posts with Categories from Wordpress Database.
 *
 * @package flashpress.vo
 * @author Dale Sattler
 **/
class WpPostCategoryVO {
	
 // The corresponding ActionScript Value Object
 //the package path of the ActionScript Object must be in here
  var $_explicitType = "flashpress.vo.WpPostCategoryVO";

  // CLASS VARIABLES
  public  $postTitle = "";
  public  $postId = 0;
  public  $categoryId = 0;
  public  $categoryName = "";
  public  $taxonomy = "";

}
?>