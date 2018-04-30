package com.babariviere.sms.status;

import android.annotation.TargetApi;
import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.provider.Telephony;
import android.telephony.SmsMessage;

import org.json.JSONException;
import org.json.JSONObject;

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
        if (getResultCode() == Activity.RESULT_OK) {
            //SmsMessage[] messages = Telephony.Sms.Intents.getMessagesFromIntent(intent);
            try {
                JSONObject stateChange = new JSONObject();

                System.out.println("extras are:");
                System.out.println(Arrays.toString(intent.getExtras().keySet().toArray()));

                stateChange.put("sentId", intent.getIntExtra("sentId", -1));
                String action = intent.getAction();


                System.out.println("action is:");
                System.out.println(action);

                System.out.println("id is:");
                System.out.println(intent.getIntExtra("sentId", -1));

                switch (action != null ? action : "none") {
                    case "SMS_SENT": {
                        stateChange.put("state", "sent");
                        break;
                    }
                    case "SMS_DELIVERED": {
                        stateChange.put("state", "delivered");
                        break;
                    }
                    default: {
                        stateChange.put("state", "none");
                    }
                }

                eventSink.success(stateChange);

            } catch (JSONException e) {
                e.printStackTrace();
                eventSink.error("#01", e.getMessage(), null);
            }
        } else {
            eventSink.error("#01", "message state change error", null);
        }
    }
}
