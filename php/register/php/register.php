<?php 

/*
use connect.php to connect out database
*/

include_once("connect.php");

/*
create POST vars to receive data from flash
*/

$username = $_POST['username'];
$password = $_POST['password'];
$userbio = $_POST['userbio'];

/*
create the mysql query
*/

$sql = "INSERT INTO users (username, password, user_bio) VALUES ('$username', '$password', '$userbio')";

mysql_query($sql) or exit("result_message=Error");

exit("result_message=Success");				  

?>
