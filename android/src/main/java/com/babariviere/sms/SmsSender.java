package com.babariviere.sms;

import android.Manifest;
import android.annotation.TargetApi;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.provider.Telephony;
import android.telephony.SmsManager;

import com.babariviere.sms.permisions.Permissions;

import org.json.JSONException;
import org.json.JSONObject;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;

import static io.flutter.plugin.common.PluginRegistry.Registrar;
import static io.flutter.plugin.common.PluginRegistry.RequestPermissionsResultListener;

/**
 * Created by babariviere on 08/03/18.
 */

@TargetApi(Build.VERSION_CODES.DONUT)
class SmsSenderMethodHandler implements RequestPermissionsResultListener {
    private static final SmsManager sms = SmsManager.getDefault();
    private final String[] permissionsList = new String[]{Manifest.permission.SEND_SMS};
    private MethodChannel.Result result;
    private String address;
    private String body;
    private final Registrar registrar;

    SmsSenderMethodHandler(Registrar registrar, MethodChannel.Result result, String address, String body) {
        this.result = result;
        this.address = address;
        this.body = body;
        this.registrar = registrar;
    }

    void handle(Permissions permissions) {
        if (permissions.checkAndRequestPermission(permissionsList, Permissions.SEND_SMS_ID_REQ)) {
            sendSmsMessage();
        }
    }

    @Override
    public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        if (requestCode != Permissions.SEND_SMS_ID_REQ) {
            return false;
        }
        boolean isOk = true;
        for (int res : grantResults) {
            if (res != PackageManager.PERMISSION_GRANTED) {
                isOk = false;
                break;
            }
        }
        if (isOk) {
            sendSmsMessage();
            return true;
        }
        result.error("#01", "permission denied for sending sms", null);
        return false;
    }

    @TargetApi(Build.VERSION_CODES.KITKAT)
    private void sendSmsMessage() {

        PendingIntent sentIntent = PendingIntent.getBroadcast(
                registrar.context(),
                0,
                new Intent("SMS_SENT"),
                0
        );

        PendingIntent deliveredIntent = PendingIntent.getBroadcast(
                registrar.context(),
                0,
                new Intent("SMS_DELIVERED"),
                0
        );

        sms.sendTextMessage(address, null, body, sentIntent, deliveredIntent);
        result.success(null);
    }
}

@TargetApi(Build.VERSION_CODES.DONUT)
class SmsSender implements MethodCallHandler {
    private final Registrar registrar;
    private final Permissions permissions;

    SmsSender(Registrar registrar) {
        this.registrar = registrar;
        permissions = new Permissions(registrar.activity());
    }

    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        if (call.method.equals("sendSMS")) {
            String address = call.argument("address");
            String body = call.argument("body");
            if (address == null) {
                result.error("#02", "missing argument 'address'", null);
            } else if (body == null) {
                result.error("#02", "missing argument 'body'", null);
            } else {
                SmsSenderMethodHandler handler = new SmsSenderMethodHandler(registrar, result, address, body);
                this.registrar.addRequestPermissionsResultListener(handler);
                handler.handle(this.permissions);
            }
        } else {
            result.notImplemented();
        }
    }
}
