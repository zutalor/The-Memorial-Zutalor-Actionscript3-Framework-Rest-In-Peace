<?php
/**
 * Vo Object for Search results Posts or Pages from Wordpress Database.
 *
 * @package flashpress.vo
 * @author Dale Sattler
 **/
 
class WpSearchVO extends WpPostVOBase {
	
 //the package path of the ActionScript Object must be in here
  var $_explicitType = "flashpress.vo.WpSearchVO";
  // CLASS VARIABLES
  public $score = 0;
  public $permalink = "";
}
?>