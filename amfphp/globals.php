<?php

	//This file is intentionally left blank so that you can add your own global settings
	//and includes which you may need inside your services. This is generally considered bad
	//practice, but it may be the only reasonable choice if you want to integrate with
	//frameworks that expect to be included as globals, for example TextPattern or WordPress

	//Set start time before loading framework
	list($usec, $sec) = explode(" ", microtime());
	$amfphp['startTime'] = ((float)$usec + (float)$sec);
	
	$servicesPath = "services/";
	$voPath = "services/vo/";
	
	
	/*************************************************************************************
	***
	***	WORDPRESS CONFIGURATION
	**
	*************************************************************************************/	
	/**
	 * Include the WordPress config files
	 */
	//this is required to bootstrap wordpress
	$configFile ='../wp-load.php';
	
	
	//if you want write access you must define this variable here
	//set this to false to disable write access to your wordpress install
	define("WPWRITEABLE",     "false");
	//then you must link to admin file here
	$wpAdminFile = '../wp-admin/includes/admin.php';
	
	if (!file_exists($configFile)) {
	    throw new Exception('WordPress wp-load.php file was not found!');
	}else{
		require_once ($configFile);
	}
	
	//check for existence of admin file and if the writeable constant is true
	if (defined('WPWRITEABLE')) {
		if (constant('WPWRITEABLE') == 'true') {
			if(!file_exists($wpAdminFile)) {
				throw new Exception('WordPress admin.php file was not found!');
			}else{
				require_once($wpAdminFile);
			}
		}
	}

?>