<?php 

/*
connect to our database
*/

include_once "connect.php";

/*
we post the variables we recieve from flash
*/

$username = $_POST['username'];
$password = $_POST['password'];

/* 
if flash called the login system the code below runs
*/

if ($_POST['systemCall'] == "checkLogin") {
	
/*
The * means the query initally selects all the records in the database.
Then the query filters out any records that are not the same as what the user entered.
*/


$sql = "SELECT * FROM users WHERE username='$username' AND password='$password'";

$query = mysql_query($sql);

/*
This counts how many records match our query
*/

$login_counter = mysql_num_rows($query);

/*
if $login_counter is greater we send a message back to flash and get the data from the database
*/

if ($login_counter > 0) {

/*
we use a while loop to get the user's bio. mysql_fetch_array gets all the field's data for the particular record.
*/

while ($data = mysql_fetch_array($query)) {
	
/*
gets the user_bio value from the selected record
*/

$userbio = $data["user_bio"];

/*
use the print function to send values back to flash
*/

print "systemResult=$userbio";

}

} else {

print "systemResult=The login details dont match our records.";

}

}

?>