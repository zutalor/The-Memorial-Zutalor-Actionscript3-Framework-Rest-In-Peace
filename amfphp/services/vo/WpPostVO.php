<?php
/**
 * Vo Object for Posts or Pages from Wordpress Database.
 *
 * @package flashpress.vo
 * @author Dale Sattler
 **/
 require('WpPostVOBase.php');
 
class WpPostVO extends WpPostVOBase {
	
 //the package path of the ActionScript Object must be in here
  var $_explicitType = "flashpress.vo.WpPostVO";
  // CLASS VARIABLES
  public $permalink = "";
}
?>