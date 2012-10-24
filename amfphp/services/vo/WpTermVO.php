<?php
/**
 * Vo Object for Terms from Wordpress Taxonomy
 *
 * @package flashpress.vo
 * @author Dale Sattler
 **/
class WpTermVO {
	
 // The corresponding ActionScript Value Object
 //the package path of the ActionScript Object must be in here
  var $_explicitType = "flashpress.vo.WpTermVO";

  // CLASS VARIABLES 
  public $name = "";
  public $slug = "";
  public $count = 0;
  public $term_group = 0;
  public $term_id = 0;
  public $taxonomy = "";
  public $term_taxonomy_id = 0;
  public $description ="";
  public $parent = 0;
}
?>