package com.babariviere.sms.status;

import android.Manifest;
import android.annotation.TargetApi;
import android.content.BroadcastReceiver;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.os.Build;
import android.provider.Telephony;

import com.babariviere.sms.permisions.Permissions;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.PluginRegistry;

/**
 * Created by Joan Pablo on 4/17/2018.
 */

public class SmsStateHandler implements EventChannel.StreamHandler, PluginRegistry.RequestPermissionsResultListener {

    private BroadcastReceiver smsStateChangeReceiver;
    final private PluginRegistry.Registrar registrar;
    private Permissions permissions;
    EventChannel.EventSink eventSink;

    public SmsStateHandler(PluginRegistry.Registrar registrar) {
        this.registrar = registrar;
        this.permissions = new Permissions(registrar.activity());
        registrar.addRequestPermissionsResultListener(this);
    }

    @TargetApi(Build.VERSION_CODES.KITKAT)
    @Override
    public void onListen(Object o, EventChannel.EventSink eventSink) {
        System.out.println("SmsStateHandler.onListen");
        smsStateChangeReceiver = new SmsStateChangeReceiver(eventSink);
        if(permissions.checkAndRequestPermission(
                new String[]{Manifest.permission.RECEIVE_SMS},
                Permissions.BROADCAST_SMS)){
            System.out.println("SmsStateHandler.onListen.hasPermissions");
            registrar.context().registerReceiver(
                    smsStateChangeReceiver,
                    new IntentFilter(Telephony.Sms.Intents.SMS_DELIVER_ACTION));
        }
    }

    @Override
    public void onCancel(Object o) {
        registrar.context().unregisterReceiver(smsStateChangeReceiver);
        smsStateChangeReceiver = null;
    }

    @TargetApi(Build.VERSION_CODES.KITKAT)
    @Override
    public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        if (requestCode != Permissions.BROADCAST_SMS) {
            return false;
        }
        boolean isOk = true;
        for (int res: grantResults) {
            if (res != PackageManager.PERMISSION_GRANTED) {
                isOk = false;
                break;
            }
        }
        if (isOk) {
            registrar.context().registerReceiver(
                    smsStateChangeReceiver,
                    new IntentFilter(Telephony.Sms.Intents.SMS_RECEIVED_ACTION));
            return true;
        }
        eventSink.error("error", "error", "error");
        eventSink.endOfStream();
        return false;
    }
}
