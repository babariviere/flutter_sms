package com.babariviere.sms;

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

  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {
    // SMS receiver
    final SmsReceiver receiver = new SmsReceiver(registrar);
    final EventChannel recvSmsChannel = new EventChannel(registrar.messenger(),
        CHANNEL_RECV, JSONMethodCodec.INSTANCE);
    recvSmsChannel.setStreamHandler(receiver);

    /// SMS sender
    final SmsSender sender = new SmsSender(registrar.activity());
    final MethodChannel sendSmsChannel = new MethodChannel(registrar.messenger(),
        CHANNEL_SEND, JSONMethodCodec.INSTANCE);
    sendSmsChannel.setMethodCallHandler(sender);
  }
}
