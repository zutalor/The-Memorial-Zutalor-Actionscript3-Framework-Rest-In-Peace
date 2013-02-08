package com.nocreativity.utils{
	import flash.events.NetStatusEvent;
	
	public class NetStatusInfo{
		public static function get NETSTREAM_BUFFER_EMPTY():InfoObject { 
           return new InfoObject("NetStream.Buffer.Empty","status","Data is not being received quickly enough to fill the buffer. Data flow will be interrupted until the buffer refills, at which time a NetStream.Buffer.Full message will be sent and the stream will begin playing again."); 
		}
		
		public static function get NETSTREAM_BUFFER_FULL():InfoObject { 
		           return new InfoObject("NetStream.Buffer.Full","status","The buffer is full and the stream will begin playing."); 
		}
		
		public static function get NETSTREAM_BUFFER_FLUSH():InfoObject { 
		           return new InfoObject("NetStream.Buffer.Flush","status","Data has finished streaming, and the remaining buffer will be emptied."); 
		}
		
		public static function get NETSTREAM_FAILED():InfoObject { 
		           return new InfoObject("NetStream.Failed","error","Flash Media Server only.    			An error has occurred for a reason other than those listed 			in other event codes."); 
		}
		
		public static function get NETSTREAM_PUBLISH_START():InfoObject { 
		           return new InfoObject("NetStream.Publish.Start","status","Publish was successful."); 
		}
		
		public static function get NETSTREAM_PUBLISH_BADNAME():InfoObject { 
		           return new InfoObject("NetStream.Publish.BadName","error","Attempt to publish a stream which is already being published by someone else."); 
		}
		
		public static function get NETSTREAM_PUBLISH_IDLE():InfoObject { 
		           return new InfoObject("NetStream.Publish.Idle","status","The publisher of the stream is idle and not transmitting data."); 
		}
		
		public static function get NETSTREAM_UNPUBLISH_SUCCESS():InfoObject { 
		           return new InfoObject("NetStream.Unpublish.Success","status","The unpublish operation was successfuul."); 
		}
		
		public static function get NETSTREAM_PLAY_START():InfoObject { 
		           return new InfoObject("NetStream.Play.Start","status","Playback has started."); 
		}
		
		public static function get NETSTREAM_PLAY_STOP():InfoObject { 
		           return new InfoObject("NetStream.Play.Stop","status","Playback has stopped."); 
		}
		
		public static function get NETSTREAM_PLAY_FAILED():InfoObject { 
		           return new InfoObject("NetStream.Play.Failed","error","An error has occurred in playback for a reason other than those listed elsewhere  			in this table, such as the subscriber not having read access."); 
		}
		
		public static function get NETSTREAM_PLAY_STREAMNOTFOUND():InfoObject { 
		           return new InfoObject("NetStream.Play.StreamNotFound","error","The FLV passed to the play() method can't be found."); 
		}
		
		public static function get NETSTREAM_PLAY_RESET():InfoObject { 
		           return new InfoObject("NetStream.Play.Reset","status","Caused by a play list reset."); 
		}
		
		public static function get NETSTREAM_PLAY_PUBLISHNOTIFY():InfoObject { 
		           return new InfoObject("NetStream.Play.PublishNotify","status","The initial publish to a stream is sent to all subscribers."); 
		}
		
		public static function get NETSTREAM_PLAY_UNPUBLISHNOTIFY():InfoObject { 
		           return new InfoObject("NetStream.Play.UnpublishNotify","status","An unpublish from a stream is sent to all subscribers."); 
		}
		
		public static function get NETSTREAM_PLAY_INSUFFICIENTBW():InfoObject { 
		           return new InfoObject("NetStream.Play.InsufficientBW","warning","Flash Media Server only. 			The client does not have sufficient bandwidth to play 			the data at normal speed."); 
		}
		
		public static function get NETSTREAM_PLAY_FILESTRUCTUREINVALID():InfoObject { 
		           return new InfoObject("NetStream.Play.FileStructureInvalid","error","The application detects an invalid file structure and will not try to play this type of file.  			For AIR and for Flash Player 9.0.115.0 and later."); 
		}
		
		public static function get NETSTREAM_PLAY_NOSUPPORTEDTRACKFOUND():InfoObject { 
		           return new InfoObject("NetStream.Play.NoSupportedTrackFound","error","The application does not detect any supported tracks (video, audio or data) and will not try to play the file.  			For AIR and for Flash Player 9.0.115.0 and later."); 
		}
		
		public static function get NETSTREAM_PLAY_TRANSITION():InfoObject { 
		           return new InfoObject("NetStream.Play.Transition","status","Flash Media Server only. The stream transitions to another as a result of bitrate stream switching. This code indicates a success status event for the NetStream.play2() call to initiate a stream switch. If the switch does not succeed, the server sends a NetStream.Play.Failed event instead. For Flash Player 10 and later. Flash Media Server 3.5 and later only. The server received the command to transition to another stream as a result of bitrate stream switching. This code indicates a success status event for the NetStream.play2() call to initiate a stream switch. If the switch does not succeed, the server sends a NetStream.Play.Failed event instead.  			When the stream switch occurs, an onPlayStatus event with a code of \"NetStream.Play.TransitionComplete\" is dispatched. For Flash Player 10 and later."); 
		}
		
		public static function get NETSTREAM_PAUSE_NOTIFY():InfoObject { 
		           return new InfoObject("NetStream.Pause.Notify","status","The stream is paused."); 
		}
		
		public static function get NETSTREAM_UNPAUSE_NOTIFY():InfoObject { 
		           return new InfoObject("NetStream.Unpause.Notify","status","The stream is resumed."); 
		}
		
		public static function get NETSTREAM_RECORD_START():InfoObject { 
		           return new InfoObject("NetStream.Record.Start","status","Recording has started."); 
		}
		
		public static function get NETSTREAM_RECORD_NOACCESS():InfoObject { 
		           return new InfoObject("NetStream.Record.NoAccess","error","Attempt to record a stream that is still playing or the client has no access right."); 
		}
		
		public static function get NETSTREAM_RECORD_STOP():InfoObject { 
		           return new InfoObject("NetStream.Record.Stop","status","Recording stopped."); 
		}
		
		public static function get NETSTREAM_RECORD_FAILED():InfoObject { 
		           return new InfoObject("NetStream.Record.Failed","error","An attempt to record a stream failed."); 
		}
		
		public static function get NETSTREAM_SEEK_FAILED():InfoObject { 
		           return new InfoObject("NetStream.Seek.Failed","error","The seek fails, which happens if the stream is not seekable."); 
		}
		
		public static function get NETSTREAM_SEEK_INVALIDTIME():InfoObject { 
		           return new InfoObject("NetStream.Seek.InvalidTime","error","For video downloaded with progressive download, the user has tried to seek or play  			past the end of the video data that has downloaded thus far, or past 			the end of the video once the entire file has downloaded. The message.details property contains a time code 			that indicates the last valid position to which the user can seek."); 
		}
		
		public static function get NETSTREAM_SEEK_NOTIFY():InfoObject { 
		           return new InfoObject("NetStream.Seek.Notify","status","The seek operation is complete."); 
		}
		
		public static function get NETCONNECTION_CALL_BADVERSION():InfoObject { 
		           return new InfoObject("NetConnection.Call.BadVersion","error","Packet encoded in an unidentified format."); 
		}
		
		public static function get NETCONNECTION_CALL_FAILED():InfoObject { 
		           return new InfoObject("NetConnection.Call.Failed","error","The NetConnection.call method was not able to invoke the server-side  			method or command."); 
		}
		
		public static function get NETCONNECTION_CALL_PROHIBITED():InfoObject { 
		           return new InfoObject("NetConnection.Call.Prohibited","error","An Action Message Format (AMF) operation is prevented for  			security reasons. Either the AMF URL is not in the same domain as the file containing the code  			calling the NetConnection.call() method, or the AMF server does not have a policy file  			that trusts the domain of the the file containing the code calling the NetConnection.call() method."); 
		}
		
		public static function get NETCONNECTION_CONNECT_CLOSED():InfoObject { 
		           return new InfoObject("NetConnection.Connect.Closed","status","The connection was closed successfully."); 
		}
		
		public static function get NETCONNECTION_CONNECT_FAILED():InfoObject { 
		           return new InfoObject("NetConnection.Connect.Failed","error","The connection attempt failed."); 
		}
		
		public static function get NETCONNECTION_CONNECT_SUCCESS():InfoObject { 
		           return new InfoObject("NetConnection.Connect.Success","status","The connection attempt succeeded."); 
		}
		
		public static function get NETCONNECTION_CONNECT_REJECTED():InfoObject { 
		           return new InfoObject("NetConnection.Connect.Rejected","error","The connection attempt did not have permission to access the application."); 
		}
		
		public static function get NETSTREAM_CONNECT_CLOSED():InfoObject { 
		           return new InfoObject("NetStream.Connect.Closed","status","The P2P connection was closed successfully.  The info.stream property indicates which stream has closed."); 
		}
		
		public static function get NETSTREAM_CONNECT_FAILED():InfoObject { 
		           return new InfoObject("NetStream.Connect.Failed","error","The P2P connection attempt failed.  The info.stream property indicates which stream has failed."); 
		}
		
		public static function get NETSTREAM_CONNECT_SUCCESS():InfoObject { 
		           return new InfoObject("NetStream.Connect.Success","status","The P2P connection attempt succeeded.  The info.stream property indicates which stream has succeeded."); 
		}
		
		public static function get NETSTREAM_CONNECT_REJECTED():InfoObject { 
		           return new InfoObject("NetStream.Connect.Rejected","error","The P2P connection attempt did not have permission to access the other peer.  The info.stream property indicates which stream was rejected."); 
		}
		
		public static function get NETCONNECTION_CONNECT_APPSHUTDOWN():InfoObject { 
		           return new InfoObject("NetConnection.Connect.AppShutdown","error","The specified application is shutting down."); 
		}
		
		public static function get NETCONNECTION_CONNECT_INVALIDAPP():InfoObject { 
		           return new InfoObject("NetConnection.Connect.InvalidApp","error","The application name specified during connect is invalid."); 
		}
		
		public static function get SHAREDOBJECT_FLUSH_SUCCESS():InfoObject { 
		           return new InfoObject("SharedObject.Flush.Success","status","The \"pending\" status is resolved and the SharedObject.flush() call succeeded."); 
		}
		
		public static function get SHAREDOBJECT_FLUSH_FAILED():InfoObject { 
		           return new InfoObject("SharedObject.Flush.Failed","error","The \"pending\" status is resolved, but the SharedObject.flush() failed."); 
		}
		
		public static function get SHAREDOBJECT_BADPERSISTENCE():InfoObject { 
		           return new InfoObject("SharedObject.BadPersistence","error","A request was made for a shared object with persistence flags, but the request cannot be granted because the object has already been created with different flags."); 
		}
		
		public static function get SHAREDOBJECT_URIMISMATCH():InfoObject { 
		           return new InfoObject("SharedObject.UriMismatch","error","An attempt was made to connect to a NetConnection object that has a different URI (URL) than the shared object."); 
		}
		
	}
}
internal class InfoObject{
	
	private var _code:String;
	private var _level:String;
	private var _meaning:String;
	
	public function InfoObject(code:String, level:String, meaning:String){
		this._code = code;
		this._level = level;
		this._meaning = meaning;
	}
	
	public function get code():String{
		return _code;
	}
	public function get level():String{
		return _level;
	}
	public function get meaning():String{
		return _meaning;
	}
	
	public function toString():String{
		return _code;
	}
}