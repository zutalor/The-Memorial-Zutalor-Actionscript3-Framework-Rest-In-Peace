<?php
/**
 * Vo Object for Options from Wordpress Database.
 *
 * @package flashpress.vo
 * @author Dale Sattler
 **/

class WpOptionVO {
	
	// The corresponding ActionScript Value Object
	 //the package path of the ActionScript Object must be in here
  	var $_explicitType = "flashpress.vo.WpOptionVO";
	
	public $option_id = 0;
	public $blog_id = 0;
	public $option_name = "";
	public $option_value ="";
	public $autoload = "";

}
?>