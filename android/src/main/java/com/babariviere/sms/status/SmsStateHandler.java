package com.babariviere.sms.status;

import android.annotation.TargetApi;
import android.content.BroadcastReceiver;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Build;
import android.provider.Telephony;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.PluginRegistry;

/**
 * Created by Joan Pablo on 4/17/2018.
 */

public class SmsStateHandler implements EventChannel.StreamHandler {

    private BroadcastReceiver smsStateChangeReceiver;
    final private PluginRegistry.Registrar registrar;

    public SmsStateHandler(PluginRegistry.Registrar registrar) {
        this.registrar = registrar;
    }

    @TargetApi(Build.VERSION_CODES.KITKAT)
    @Override
    public void onListen(Object o, EventChannel.EventSink eventSink) {
        smsStateChangeReceiver = new SmsStateChangeReceiver(eventSink);
        registrar.context().registerReceiver(
                smsStateChangeReceiver,
                new IntentFilter(Telephony.Sms.Intents.SMS_RECEIVED_ACTION));
    }

    @Override
    public void onCancel(Object o) {
        registrar.context().unregisterReceiver(smsStateChangeReceiver);
        smsStateChangeReceiver = null;
    }
}
