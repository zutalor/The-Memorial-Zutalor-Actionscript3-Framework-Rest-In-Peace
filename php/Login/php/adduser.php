<?php 

/*
connect to the database
*/

require_once "connect.php";

/*
create the mysql query

What this query means is php calls mysql to insert values into the table users. It then asks for the fields you want to add data to then the values for that certain field.

*/

$sql = "INSERT INTO users (username, password, user_bio) VALUES ('test1', 'password1', 'This is the additional users bio')";

$query = mysql_query($sql);

mysql_close();

?>