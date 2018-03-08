package com.babariviere.sms;

import android.Manifest;
import android.app.Activity;
import android.content.pm.PackageManager;
import android.os.Build;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.JSONMethodCodec;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * SmsPlugin
 */
public class SmsPlugin {
  private static final String CHANNEL_RECV = "plugins.babariviere.com/recvSMS";
  private static final String CHANNEL_SEND = "plugins.babariviere.com/sendSMS";
  private static final int RECV_SMS_ID_REQ = 1;
  private static final int SEND_SMS_ID_REQ = 2;
  private static final int READ_PHONE_ID_REQ = 2;
  private Activity activity;

  SmsPlugin(Registrar registrar) {
    this.activity = registrar.activity();
  }

  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {
    final SmsPlugin plugin = new SmsPlugin(registrar);
    plugin.checkAndRequestPermission(Manifest.permission.RECEIVE_SMS, RECV_SMS_ID_REQ);
    plugin.checkAndRequestPermission(Manifest.permission.SEND_SMS, SEND_SMS_ID_REQ);
    plugin.checkAndRequestPermission(Manifest.permission.READ_PHONE_STATE, READ_PHONE_ID_REQ);

    // SMS receiver
    final SmsReceiver receiver = new SmsReceiver(registrar);
    final EventChannel recvSmsChannel = new EventChannel(registrar.messenger(),
        CHANNEL_RECV, JSONMethodCodec.INSTANCE);
    recvSmsChannel.setStreamHandler(receiver);

    /// SMS sender
    final SmsSender sender = new SmsSender();
    final MethodChannel sendSmsChannel = new MethodChannel(registrar.messenger(),
        CHANNEL_SEND, JSONMethodCodec.INSTANCE);
    sendSmsChannel.setMethodCallHandler(sender);
  }

  private boolean hasPermission(String permission) {
    return (Build.VERSION.SDK_INT < Build.VERSION_CODES.M ||
        activity.checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED);
  }

  private void checkAndRequestPermission(String permission, int id) {
    if (!hasPermission(permission)) {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
        activity.requestPermissions(new String[]{permission}, id);
      }
    }
  }
}
