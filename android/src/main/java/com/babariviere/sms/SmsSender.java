package com.babariviere.sms;

import android.annotation.TargetApi;
import android.os.Build;
import android.telephony.SmsManager;
import android.util.Log;


import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;

/**
 * Created by babariviere on 08/03/18.
 */

@TargetApi(Build.VERSION_CODES.DONUT)
public class SmsSender implements MethodCallHandler {
  static SmsManager sms = SmsManager.getDefault();

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    // TODO: ask for permissions
    if (call.method.equals("sendSMS")) {
      String dest = call.argument("address");
      String body = call.argument("body");
      if (dest == null) {
        result.error(null, "missing argument 'address'", null);
      } else if (body == null) {
        result.error(null, "missing argument 'body'", null);
      } else {
        sms.sendTextMessage(dest, null, body, null, null);
        result.success(null);
      }
    } else {
      result.notImplemented();
    }
  }
}
