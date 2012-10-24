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
class SaveJPEG
{	
	// change this according to your AMFPHP installation.
	var $server_url = "http://localhost/amfphp/services/";
	var $output_dir = "upload";

	/**
	 * Save image from the given bytearray
	 * and return the path of the saved image
	 */
	function SaveAsJPEG($ba, $compressed = false, $oParams = "empty object")
	{
		if(!file_exists($this->output_dir) || !is_writeable($this->output_dir))
			trigger_error ("please create a directory named '".$this->output_dir."' with write access in ".$this->server_url, E_USER_ERROR);

		$data = $ba->data;
		if($compressed)
		{
			if(function_exists(gzuncompress))
			{
				$data = gzuncompress($data);
			} else {
				trigger_error ("gzuncompress method does not exists, please send uncompressed data", E_USER_ERROR);
			}
		}
		file_put_contents($this->output_dir . "/upload_".date("Ymd")."_".time().".jpg", $data);
		return $this->server_url . $this->output_dir . "/upload_".date("Ymd")."_".time().".jpg";
	}

	/**
	 * Save file from a given bytearray
	 * and return a ByteArray from the saved file
	 */
	function SaveAsByteArray($ba, $compresses = false, $oParams = "empty object")
	{
		if(!file_exists($this->output_dir) || !is_writeable($this->output_dir))
			trigger_error ("please create a directory named '".$this->output_dir."' with write access in ".$this->server_url, E_USER_ERROR);

		$data = $ba->data;
		if($compressed)
		{
			if(function_exists(gzuncompress))
			{
				$data = gzuncompress($data);
			} else {
				trigger_error ("gzuncompress method does not exists, please send uncompressed data", E_USER_ERROR);
			}
		}
		file_put_contents($this->output_dir . "/upload_".date("Ymd")."_".time().".rgb", $data);
		return new ByteArray(file_get_contents($this->output_dir . "/upload_".date("Ymd")."_".time().".rgb"));
	}
}
?>