package com.babariviere.sms.status;

import android.annotation.TargetApi;
import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.provider.Telephony;
import android.telephony.SmsMessage;

import java.util.Arrays;

import io.flutter.plugin.common.EventChannel;

/**
 * Created by Joan Pablo on 4/17/2018.
 */

public class SmsStateChangeReceiver extends BroadcastReceiver {
    private EventChannel.EventSink eventSink;

    public SmsStateChangeReceiver(EventChannel.EventSink eventSink) {
        this.eventSink = eventSink;
    }

    @TargetApi(Build.VERSION_CODES.KITKAT)
    @Override
    public void onReceive(Context context, Intent intent) {
        System.out.println("onReceive");
        if (getResultCode() == Activity.RESULT_OK) {
            if (intent.getExtras() != null) {
                System.out.println("format: " + intent.getStringExtra("format"));
                System.out.println(Arrays.toString(intent.getByteArrayExtra("pdu")));
            }
            eventSink.success("received");
        }
        else {
            eventSink.error("bad", "bad", "bad");
        }
    }
}
