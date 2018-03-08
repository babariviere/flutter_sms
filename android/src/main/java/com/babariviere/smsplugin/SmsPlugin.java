package com.babariviere.smsplugin;

import android.Manifest;
import android.annotation.TargetApi;
import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.provider.Telephony;
import android.telephony.SmsMessage;
import android.util.Log;

import org.json.JSONObject;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * SmsPlugin
 */
public class SmsPlugin {
  private Activity activity;

  private static final String CHANNEL_REC = "plugins.babariviere.com/recvSms";

  private int RECEIVE_SMS_ID_REQ = 0;

  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {
    final SmsPlugin plugin = new SmsPlugin(registrar);
    plugin.checkAndRequestPermission(Manifest.permission.RECEIVE_SMS);

    // SMS receiver
    final SmsReceiver receiver = new SmsReceiver(registrar);
    final EventChannel getSmsChannel = new EventChannel(registrar.messenger(),
        CHANNEL_REC);
    getSmsChannel.setStreamHandler(receiver);
  }

  private boolean hasPermission(String permission) {
    return (Build.VERSION.SDK_INT < Build.VERSION_CODES.M ||
        activity.checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED);
  }

  private void checkAndRequestPermission(String permission) {
    if (!hasPermission(permission)) {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
        activity.requestPermissions(new String[] {permission}, RECEIVE_SMS_ID_REQ);
      }
    }
  }

  SmsPlugin(Registrar registrar) {
    this.activity = registrar.activity();
  }
}
