<?php
/**
 * Vo Object for User information from Wordpress Database.
 *
 * @package flashpress.vo
 * @author Dale Sattler
 **/
class WpUserVO {
	
   // The corresponding ActionScript Value Object
   //the package path of the ActionScript Object must be in here
   var $_explicitType = "flashpress.vo.WpUserVO";

	public $user_id = 0;
	public $user_login = "";
	public $user_pass = "";
	public $user_nicename = "";
	public $user_email = "";
	public $user_url ="";
	public $user_registered = "";
	public $user_activation_key = "";
	public $user_status = 0;
	public $user_display_name = "";
}
?>
