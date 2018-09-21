package com.babariviere.sms;

import android.annotation.TargetApi;
import android.content.ContentValues;
import android.net.Uri;
import android.os.Build;
import android.provider.Telephony;

import com.babariviere.sms.permisions.Permissions;

import java.security.Permission;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

public class SmsDb implements MethodChannel.MethodCallHandler, PluginRegistry.RequestPermissionsResultListener {
    private PluginRegistry.Registrar registrar;
    private String address;
    private String body;
    private long date;
    private long dateSent;
    private int read;
    private int kind;

    SmsDb(PluginRegistry.Registrar registrar) {
        this.registrar = registrar;
    }

    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        if (methodCall.method.equals("insert")) {
            this.address = methodCall.argument("address");
            this.body = methodCall.argument("body");
            this.date = methodCall.argument("date");
            this.dateSent = methodCall.argument("dateSent");
            this.read = methodCall.argument("read");
            this.kind = methodCall.argument("kind");
            insertMessage(result);
        } else {
            result.notImplemented();
        }
    }

    @TargetApi(Build.VERSION_CODES.KITKAT)
    private void insertMessage(MethodChannel.Result result) {
        ContentValues cv = new ContentValues();
        cv.put(Telephony.Sms.ADDRESS, this.address);
        cv.put(Telephony.Sms.BODY, this.body);
        cv.put(Telephony.Sms.DATE, this.date);
        cv.put(Telephony.Sms.DATE_SENT, this.dateSent);
        cv.put(Telephony.Sms.READ, this.read);
        Uri box;
        switch (kind) {
            case 0:
                box = Telephony.Sms.Outbox.CONTENT_URI;
                break;
            case 1:
                box = Telephony.Sms.Inbox.CONTENT_URI;
                break;
            case 2:
                box = Telephony.Sms.Draft.CONTENT_URI;
                break;
            default:
                box = Telephony.Sms.Inbox.CONTENT_URI;
        }

        Uri u = registrar.context().getContentResolver().insert(box, cv);
        if (u != null) {
            result.success(null);
        } else {
            result.error("#01", "cannot insert message into db", null);
        }
    }

    @Override
    public boolean onRequestPermissionsResult(int i, String[] strings, int[] ints) {
        return false;
    }
}
