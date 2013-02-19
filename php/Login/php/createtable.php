<?php

/*
connect to our database
*/

require_once "connect.php";

/*
create the mysql query
*/

$sql = "CREATE TABLE users (
							
		id int(11) NOT NULL auto_increment,
		username varchar(255) NOT NULL,
		password varchar(255) NOT NULL,
		user_bio longtext NOT NULL,
		PRIMARY KEY (id)
		
		)";

$query = mysql_query($sql);

if ($query === TRUE) {

echo 'You have successfully created your table';

}

mysql_close();

?>