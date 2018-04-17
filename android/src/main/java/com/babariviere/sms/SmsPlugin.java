package com.babariviere.sms;

import com.babariviere.sms.permisions.Permissions;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.JSONMethodCodec;
import io.flutter.plugin.common.StandardMethodCodec;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * SmsPlugin
 */
public class SmsPlugin {
  private static final String CHANNEL_RECV = "plugins.babariviere.com/recvSMS";
  private static final String CHANNEL_SEND = "plugins.babariviere.com/sendSMS";
  private static final String CHANNEL_QUER = "plugins.babariviere.com/querySMS";
  private static final String CHANNEL_QUER_CONT = "plugins.babariviere.com/queryContact";
  private static final String CHANNEL_QUER_CONT_PHOTO = "plugins.babariviere.com/queryContactPhoto";
  private static final String USER_PROFILE = "plugins.babariviere.com/userProfile";

  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {

    registrar.addRequestPermissionsResultListener(Permissions.getRequestsResultsListener());

    // SMS receiver
    final SmsReceiver receiver = new SmsReceiver(registrar);
    final EventChannel recvSmsChannel = new EventChannel(registrar.messenger(),
        CHANNEL_RECV, JSONMethodCodec.INSTANCE);
    recvSmsChannel.setStreamHandler(receiver);

    /// SMS sender
    final SmsSender sender = new SmsSender(registrar);
    final MethodChannel sendSmsChannel = new MethodChannel(registrar.messenger(),
        CHANNEL_SEND, JSONMethodCodec.INSTANCE);
    sendSmsChannel.setMethodCallHandler(sender);

    /// SMS query
    final SmsQuery query = new SmsQuery(registrar);
    final MethodChannel querySmsChannel = new MethodChannel(registrar.messenger(), CHANNEL_QUER, JSONMethodCodec.INSTANCE);
    querySmsChannel.setMethodCallHandler(query);

    /// Contact query
    final ContactQuery contactQuery = new ContactQuery(registrar);
    final MethodChannel queryContactChannel = new MethodChannel(registrar.messenger(), CHANNEL_QUER_CONT, JSONMethodCodec.INSTANCE);
    queryContactChannel.setMethodCallHandler(contactQuery);

    /// Contact Photo query
    final ContactPhotoQuery contactPhotoQuery = new ContactPhotoQuery(registrar);
    final MethodChannel queryContactPhotoChannel = new MethodChannel(registrar.messenger(), CHANNEL_QUER_CONT_PHOTO, StandardMethodCodec.INSTANCE);
    queryContactPhotoChannel.setMethodCallHandler(contactPhotoQuery);

    /// User Profile
    final UserProfileProvider userProfileProvider = new UserProfileProvider(registrar);
    final MethodChannel userProfileProviderChannel = new MethodChannel(registrar.messenger(), USER_PROFILE, JSONMethodCodec.INSTANCE);
    userProfileProviderChannel.setMethodCallHandler(userProfileProvider);
  }
}
