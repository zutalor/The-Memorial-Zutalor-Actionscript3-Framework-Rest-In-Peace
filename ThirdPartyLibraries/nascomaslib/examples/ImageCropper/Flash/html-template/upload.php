<?php
/*
Copyright (c) 2008 NascomASLib Contributors.  See:
    http://code.google.com/p/nascomaslib

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/
function printResult($success, $errors, $data, $onlineFileLocation) 
{
	echo("<?xml version=\"1.0\" encoding=\"utf-8\"?>\n");	
	echo("<results>\n");	
	echo("<success><![CDATA[$success]]></success>\n");
	echo("<location><![CDATA[$onlineFileLocation]]></location>\n");
    echo("<data><![CDATA[$data]]></data>\n");
	for($i=0;$i<count($errors);$i++) {
		echo("<error><![CDATA[".$errors[$i]."]]></error>\n");
	}
	echo("</results>\n");	
}

$errors = array();
$data = $_POST['data'];
$success = "false";
$file_temp = $_FILES['Filedata']['tmp_name'];
$file_name = "upload_".date("Ymd")."_".time()."_".$_FILES['Filedata']['name'];
$file_path = $_SERVER['DOCUMENT_ROOT']."/_scripts/upload/";
$onlineFileLocation = "";

//checks for duplicate files
if(!file_exists($file_path.$file_name)) {
	//complete upload
	$filestatus = move_uploaded_file($file_temp, utf8_decode($file_path.$file_name) );
	$onlineFileLocation = $file_path.$file_name;
	if(!$filestatus) {
		$success = "false";
		array_push($errors,"Upload failed. Please try again.");
	}
}else {
	$success = "false";
	array_push($errors,"File already exists on server.");
}

printResult($success, $errors, $data, $onlineFileLocation);
?>
