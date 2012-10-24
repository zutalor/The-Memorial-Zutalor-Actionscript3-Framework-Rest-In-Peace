<?php

class Email
{	
	/**
	 * This service sends an email
	 * @returns true or false
	 */
	function send($to, $from, $subject, $message)
	{
		$headers = 'From: ' . $from . "\r\n" .
		'Reply-To:' . $from . "\r\n" .
		'X-Mailer: PHP/' . phpversion();		
		
		return mail($to, $subject, $message, $headers);
	}
}

?>