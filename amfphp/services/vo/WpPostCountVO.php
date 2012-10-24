<?php
/**
 * Vo Object for post count information from Wordpress Database.
 *
 * @package flashpress.vo
 * @author Dale Sattler
 **/
class WpPostCountVO {
	
   // The corresponding ActionScript Value Object
   //the package path of the ActionScript Object must be in here
   var $_explicitType = "flashpress.vo.WpPostCountVO";
	
	public $publish = 0;
	public $draft = 0;
	public $private_post = 0;
	public $pending = 0;
	public $future = 0;
}
?>
