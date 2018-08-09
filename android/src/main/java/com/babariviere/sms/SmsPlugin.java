package com.babariviere.sms;

import com.babariviere.sms.permisions.Permissions;
import com.babariviere.sms.status.SmsStateHandler;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.JSONMethodCodec;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.StandardMethodCodec;

/**
 * SmsPlugin
 */
public class SmsPlugin {
    private static final String CHANNEL_RECV = "plugins.babariviere.com/recvSMS";
    private static final String CHANNEL_SMS_STATUS = "plugins.babariviere.com/statusSMS";
    private static final String CHANNEL_SEND = "plugins.babariviere.com/sendSMS";
    private static final String CHANNEL_QUER = "plugins.babariviere.com/querySMS";
    private static final String CHANNEL_QUER_CONT = "plugins.babariviere.com/queryContact";
    private static final String CHANNEL_QUER_CONT_PHOTO = "plugins.babariviere.com/queryContactPhoto";
    private static final String CHANNEL_USER_PROFILE = "plugins.babariviere.com/userProfile";
    private static final String CHANNEL_SIM_CARDS = "plugins.babariviere.com/simCards";

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {

        registrar.addRequestPermissionsResultListener(Permissions.getRequestsResultsListener());

        // SMS receiver
        final SmsReceiver receiver = new SmsReceiver(registrar);
        final EventChannel receiveSmsChannel = new EventChannel(registrar.messenger(),
                CHANNEL_RECV, JSONMethodCodec.INSTANCE);
        receiveSmsChannel.setStreamHandler(receiver);

        // SMS status receiver
        new EventChannel(registrar.messenger(), CHANNEL_SMS_STATUS, JSONMethodCodec.INSTANCE)
                .setStreamHandler(new SmsStateHandler(registrar));

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
        final MethodChannel userProfileProviderChannel = new MethodChannel(registrar.messenger(), CHANNEL_USER_PROFILE, JSONMethodCodec.INSTANCE);
        userProfileProviderChannel.setMethodCallHandler(userProfileProvider);

        //Sim Cards Provider
        new MethodChannel(registrar.messenger(), CHANNEL_SIM_CARDS, JSONMethodCodec.INSTANCE)
                .setMethodCallHandler(new SimCardsProvider(registrar));
    }
}
