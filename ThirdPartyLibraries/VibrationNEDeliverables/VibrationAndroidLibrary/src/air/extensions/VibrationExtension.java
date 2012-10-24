/*ADOBE SYSTEMS INCORPORATED
Copyright 2011 Adobe Systems Incorporated
All Rights Reserved.

NOTICE:  Adobe permits you to use, modify, and distribute this file in accordance with the 
terms of the Adobe license agreement accompanying it.  If you have received this file from a 
source other than Adobe, then your use, modification, or distribution of it requires the prior 
written permission of Adobe.
 */

package air.extensions;

import android.util.Log;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREExtension;

// Class VibrationExtension
//

public class VibrationExtension implements FREExtension
{

	// createContext() creates and returns an FREContext object.
	public FREContext createContext(String extId)
	{
		Log.i("VibrationExtension", "createContext");

		return new VibrationExtensionContext();

	}

	// initialize() performs initializations for the extension.
	public void initialize()
	{
		Log.i("VibrationExtension", "initialize");
	}

	// dispose() cleans up extension resources.
	public void dispose()
	{
		Log.i("VibrationExtension", "dispose");
	}

}
