<?php

class Analytics
{	
	/**
	 * 
	 * @returns versionVO
	 */
	public function log($ip, $version, $data)
	{
		$logfile="SoundScience.csv";
		$fh = fopen($logfile, 'a') or die("can't open file");
		fwrite($fh, $ip . ',' . $version . "," . $data "\n");
		fclose($fh);
		return true;
	}
}

?>