<?php

class Analytics
{	
	/**
	 * 
	 * @returns versionVO
	 */
	public function log($app, $version, $date, $usertime, $capabilities)
	{
		$logfile="analytics_feb2011.txt";
		$fh = fopen($logfile, 'a') or die("can't open file");
		fwrite($fh, $app . ' ' . $version . " " . $date . ' ' . ' ' . $usertime . ' ' . $capabilities . "\n");
		fclose($fh);
		return true;
	}
}

?>