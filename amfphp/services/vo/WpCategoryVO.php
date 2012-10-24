<?php
/**
 * Vo Object for Categories from Wordpress Database.
 *
 * @package flashpress.vo
 * @author Dale Sattler
 **/
class WpCategoryVO {
	
// The corresponding ActionScript Value Object
 //the package path of the ActionScript Object must be in here
  var $_explicitType = "flashpress.vo.WpCategoryVO";
  
  public $category_count = 0;
  public $category_description = "";
  public $category_nicename = "";
  public $category_parent = 0;
  public $cat_ID = 0;
  public $cat_name = "";
  public $count = 0;
  public $description = "";
  public $name = "";
  public $parent = 0;  
  public $slug = "";
  public $taxonomy = "";
  public $term_id = 0;
  public $term_group = 0;
  public $term_taxonomy_id = 0;        
}
?>