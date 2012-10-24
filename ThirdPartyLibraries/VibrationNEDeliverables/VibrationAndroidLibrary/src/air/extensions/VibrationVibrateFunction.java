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
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;

// Class VibrationVibrateFunction
//
// This class makes the device vibrate.
//
// The passedArgs array in call() contains one argument: the duration in milliseconds to vibrate the device.

public class VibrationVibrateFunction implements FREFunction {

	@Override
	public FREObject call(FREContext context, FREObject[] passedArgs) {

		FREObject result = null;

		Log.i ("VibrationVibrateFunction", "call");

		VibrationExtensionContext vibExtContext = (VibrationExtensionContext) context;

		try {

			FREObject fro = passedArgs[0];

			int duration = fro.getAsInt();

			Log.i("VibrationVibrateFunction", "call: duration value is " + Integer.toString(duration));

			vibExtContext.androidVibrator.vibrate(duration);
		}

		catch (Exception e) {

			Log.i ("VibrationVibrateFunction", e.getMessage());
		}

		return result;
	}
}
