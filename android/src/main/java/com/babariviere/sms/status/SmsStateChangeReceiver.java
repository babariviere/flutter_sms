package com.babariviere.sms.status;

import android.annotation.TargetApi;
import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.telephony.SmsManager;
import android.util.Log;

import org.json.JSONException;
import org.json.JSONObject;

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
        try {
            JSONObject stateChange = new JSONObject();
            stateChange.put("sentId", intent.getIntExtra("sentId", -1));
            String action = intent.getAction();

            switch (action != null ? action : "none") {
                case "SMS_SENT": {
                    if (getResultCode() != Activity.RESULT_OK) {
                        stateChange.put("state", "fail");
                    } else {
                        stateChange.put("state", "sent");
                    }
                    Log.d("flutter_sms", "Sent result: " + sentResult(getResultCode()));
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
    }

    String sentResult(int resultCode) {
        switch (resultCode) {
            case Activity.RESULT_OK:
                return "Activity.RESULT_OK";
            case SmsManager.RESULT_ERROR_GENERIC_FAILURE:
                return "SmsManager.RESULT_ERROR_GENERIC_FAILURE";
            case SmsManager.RESULT_ERROR_RADIO_OFF:
                return "SmsManager.RESULT_ERROR_RADIO_OFF";
            case SmsManager.RESULT_ERROR_NULL_PDU:
                return "SmsManager.RESULT_ERROR_NULL_PDU";
            case SmsManager.RESULT_ERROR_NO_SERVICE:
                return "SmsManager.RESULT_ERROR_NO_SERVICE";
            default:
                return "Unknown error code";
        }
    }
}
