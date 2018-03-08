package com.babariviere.sms;

import android.annotation.TargetApi;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Build;
import android.os.Bundle;
import android.provider.Telephony;
import android.telephony.SmsMessage;

import org.json.JSONObject;

import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.PluginRegistry;

/**
 * Created by babariviere on 08/03/18.
 */

public class SmsReceiver implements StreamHandler {
  private PluginRegistry.Registrar registrar;
  private BroadcastReceiver receiver;

  SmsReceiver(PluginRegistry.Registrar registrar) {
    this.registrar = registrar;
  }

  @Override
  public void onListen(Object arguments, EventSink events) {
    receiver = createSmsReceiver(events);
    // TODO: close stream if we don't have permission
    registrar.context().registerReceiver(receiver, new IntentFilter(Telephony.Sms.Intents.SMS_RECEIVED_ACTION));
  }

  @Override
  public void onCancel(Object o) {
    registrar.context().unregisterReceiver(receiver);
    receiver = null;
  }

  @TargetApi(Build.VERSION_CODES.DONUT)
  private SmsMessage[] readMessages(Intent intent) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
      SmsMessage[] msgs = Telephony.Sms.Intents.getMessagesFromIntent(intent);
      return msgs;
    }
    Bundle bundle = intent.getExtras();

    if (bundle == null || !bundle.containsKey("pdus")) {
      return null;
    }
    final Object pdus[] = (Object[]) bundle.get("pdus");
    SmsMessage[] msgs = new SmsMessage[pdus.length];
    int idx = 0;
    for (Object pdu: pdus) {
      msgs[idx] = SmsMessage.createFromPdu((byte[]) pdu);
      idx++;
    }
    return msgs;
  }

  private BroadcastReceiver createSmsReceiver(final EventSink events) {
    return new BroadcastReceiver() {
      @TargetApi(Build.VERSION_CODES.DONUT)
      @Override
      public void onReceive(Context context, Intent intent) {
        try {
          SmsMessage[] msgs = readMessages(intent);
          if (msgs == null) {
            return;
          }
          for (SmsMessage msg: msgs) {
            JSONObject obj = new JSONObject();
            obj.put("sender", msg.getOriginatingAddress());
            obj.put("body", msg.getMessageBody());
            events.success(obj.toString());
          }
        } catch (Exception e) {}
      }
    };
  }
}