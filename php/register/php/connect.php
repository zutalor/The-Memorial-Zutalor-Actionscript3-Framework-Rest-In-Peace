<?php

/*
Database vars that we use to connect to our mysql database. Change the values to your database settings.
*/

$db_name = "admin";

$db_username = "root";

$db_password = "root";

$db_host = "localhost";

/*
mysql_connect is a built function that allows us to make an easy connection
*/

mysql_connect($db_host, $db_username, $db_password, $db_name);

/*
mysql_select_db is a built in function that allows us to select the database. This is an essential function.

We use the die function to check for errors.

*/ 

mysql_select_db($db_name) or die (mysql_error());

?>