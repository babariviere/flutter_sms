package com.babariviere.sms;

import android.Manifest;
import android.annotation.TargetApi;
import android.app.Activity;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.os.Build;
import android.telephony.SmsManager;
import android.util.Log;

import com.babariviere.sms.permisions.Permissions;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.PluginRegistry;

import static io.flutter.plugin.common.PluginRegistry.Registrar;
import static io.flutter.plugin.common.PluginRegistry.RequestPermissionsResultListener;

/**
 * Created by babariviere on 08/03/18.
 */

@TargetApi(Build.VERSION_CODES.DONUT)
class SmsSenderMethodHandler implements RequestPermissionsResultListener, PluginRegistry.NewIntentListener {
  private static final SmsManager sms = SmsManager.getDefault();
  private final String[] permissionsList = new String[]{Manifest.permission.SEND_SMS};
  private Registrar registrar;
  private MethodChannel.Result result;
  private MethodChannel channel;
  private String address;
  private String body;
  private String callbackName;

  SmsSenderMethodHandler(Registrar registrar, MethodChannel.Result result, MethodChannel channel, String address, String body, String callbackName) {
    this.registrar = registrar;
    this.result = result;
    this.channel = channel;
    this.address = address;
    this.body = body;
    this.callbackName = callbackName;
  }

  void handle(Permissions permissions) {
    if (permissions.checkAndRequestPermission(permissionsList, Permissions.SEND_SMS_ID_REQ)) {
      sendSMS();
    }
  }

  private void sendSMS() {
    String SENT = "SMS_SENT";
    String DELIVERED = "SMS_DELIVERED";
    PendingIntent sentPI = null;
    PendingIntent deliveryPI = null;
    if (callbackName != null) {
      Intent sentIntent = new Intent(SENT);
      sentIntent.putExtra("callback", this.callbackName);
      sentIntent.putExtra("value", 1);
      Intent deliveryIntent = new Intent(DELIVERED);
      deliveryIntent.putExtra("callback", this.callbackName);
      deliveryIntent.putExtra("value", 2);
      sentPI = PendingIntent.getBroadcast(this.registrar.context(), 0, sentIntent, 0);
      deliveryPI = PendingIntent.getBroadcast(this.registrar.context(), 0, deliveryIntent, 0);
      this.registrar.context().registerReceiver(getSentReceiver(this.channel, this.callbackName), new IntentFilter(SENT));
      this.registrar.context().registerReceiver(getDeliveredReceiver(this.channel, this.callbackName), new IntentFilter(DELIVERED));
      this.registrar.addNewIntentListener(this);
    }
    sms.sendTextMessage(address, null, body, sentPI, deliveryPI);
    result.success(null);
  }

  private BroadcastReceiver getSentReceiver(final MethodChannel channel, final String callbackName) {
    return new BroadcastReceiver() {
      @Override
      public void onReceive(Context context, Intent intent) {
        if (getResultCode() == Activity.RESULT_OK) {
          Log.d("DEBUG", "Calling " + callbackName);
          channel.invokeMethod(callbackName, 1);
        }
      }
    };
  }

  private BroadcastReceiver getDeliveredReceiver(final MethodChannel channel, final String callbackName) {
    return new BroadcastReceiver() {
      @Override
      public void onReceive(Context context, Intent intent) {
        if (getResultCode() == Activity.RESULT_OK) {
          Log.d("DEBUG", "Calling " + callbackName);
          Log.d("CHANNEL", channel.toString());
          channel.invokeMethod(callbackName, 2);
        }
      }
    };
  }

  @Override
  public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
    if (requestCode != Permissions.SEND_SMS_ID_REQ) {
      return false;
    }
    boolean isOk = true;
    for (int res : grantResults) {
      if (res != PackageManager.PERMISSION_GRANTED) {
        isOk = false;
        break;
      }
    }
    if (isOk) {
      sendSMS();
      return true;
    }
    result.error("#01", "permission denied", null);
    return false;
  }

  @Override
  public boolean onNewIntent(Intent intent) {
    String callback = intent.getStringExtra("callback");
    int value = intent.getIntExtra("value", 0);
    if (value == 0 || callback == null)
      return false;
    channel.invokeMethod(callback, value);
    return true;
  }
}

@TargetApi(Build.VERSION_CODES.DONUT)
class SmsSender implements MethodCallHandler {
  private final Registrar registrar;
  private final Permissions permissions;
  private final MethodChannel channel;

  SmsSender(Registrar registrar, MethodChannel channel) {
    this.registrar = registrar;
    this.channel = channel;
    permissions = new Permissions(registrar.activity());
  }

  // TODO: event channel with unique ID

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    if (call.method.equals("sendSMS")) {
      Log.d("DEBUG", call.arguments.toString());
      String address = call.argument("address");
      String body = call.argument("body");
      String callback = call.argument("callback");
      if (address == null) {
        result.error("#02", "missing argument 'address'", null);
      } else if (body == null) {
        result.error("#02", "missing argument 'body'", null);
      } else {
        SmsSenderMethodHandler handler = new SmsSenderMethodHandler(registrar, result, channel, address, body, callback);
        this.registrar.addRequestPermissionsResultListener(handler);
        handler.handle(this.permissions);

      }
    } else {
      result.notImplemented();
    }
  }
}
