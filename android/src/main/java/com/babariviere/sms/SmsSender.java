package com.babariviere.sms;

import android.Manifest;
import android.annotation.TargetApi;
import android.app.Activity;
import android.os.Build;
import android.telephony.SmsManager;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;

/**
 * Created by babariviere on 08/03/18.
 */

@TargetApi(Build.VERSION_CODES.DONUT)
class SmsSender implements MethodCallHandler {
  private static final SmsManager sms = SmsManager.getDefault();
  private final Permissions permissions;
  private final String[] permissions_list = new String[]{Manifest.permission.SEND_SMS, Manifest.permission.READ_PHONE_STATE};

  SmsSender(Activity activity) {
    permissions = new Permissions(activity);
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    if (!permissions.checkAndRequestPermission(permissions_list, Permissions.SEND_SMS_ID_REQ)) {
      result.error(null, "permission denied", null);
      return;
    }
    if (call.method.equals("sendSMS")) {
      String dest = call.argument("address");
      String body = call.argument("body");
      if (dest == null) {
        result.error("#02", "missing argument 'address'", null);
      } else if (body == null) {
        result.error("#02", "missing argument 'body'", null);
      } else {
        sms.sendTextMessage(dest, null, body, null, null);
        result.success(null);
      }
    } else {
      result.notImplemented();
    }
  }
}
