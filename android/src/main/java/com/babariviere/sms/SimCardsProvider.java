package com.babariviere.sms;

import android.Manifest;
import android.annotation.TargetApi;
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Build;

import com.babariviere.sms.permisions.Permissions;
import com.babariviere.sms.telephony.TelephonyManager;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

class SimCardsHandler implements PluginRegistry.RequestPermissionsResultListener {
    private final String[] permissionsList = new String[]{Manifest.permission.READ_PHONE_STATE};
    private PluginRegistry.Registrar registrar;
    private MethodChannel.Result result;

    SimCardsHandler(PluginRegistry.Registrar registrar, MethodChannel.Result result) {
        this.registrar = registrar;
        this.result = result;
    }

    @Override
    public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        if (requestCode != Permissions.READ_PHONE_STATE) {
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
            getSimCards();
            return true;
        }
        result.error("#01", "permission denied", null);
        return false;
    }

    void handle(Permissions permissions) {
        if (permissions.checkAndRequestPermission(permissionsList, Permissions.READ_PHONE_STATE)) {
            getSimCards();
        }
    }

    private void getSimCards() {
        JSONArray simCards = new JSONArray();

        try {
            TelephonyManager telephonyManager = new TelephonyManager(registrar.context());
            int phoneCount = telephonyManager.getSimCount();
            for (int i = 0; i < phoneCount; i++) {
                JSONObject simCard = new JSONObject();
                simCard.put("slot", i + 1);
                simCard.put("imei", telephonyManager.getSimId(i));
                simCard.put("state", telephonyManager.getSimState(i));
                simCards.put(simCard);
            }
        } catch (JSONException e) {
            e.printStackTrace();
            result.error("2", e.getMessage(), null);
            return;
        }

        result.success(simCards);
    }
}

class SimCardsProvider implements MethodChannel.MethodCallHandler {
    private final Permissions permissions;
    private final PluginRegistry.Registrar registrar;

    SimCardsProvider(PluginRegistry.Registrar registrar) {
        this.registrar = registrar;
        permissions = new Permissions(registrar.activity());
    }

    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        if (!call.method.equals("getSimCards")) {
            result.notImplemented();
        } else {
            getSimCards(result);
        }
    }

    private void getSimCards(MethodChannel.Result result) {
        SimCardsHandler handler = new SimCardsHandler(registrar, result);
        this.registrar.addRequestPermissionsResultListener(handler);
        handler.handle(permissions);
    }
}