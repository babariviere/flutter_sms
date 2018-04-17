package com.babariviere.sms;

import android.annotation.TargetApi;
import android.app.Activity;
import android.content.pm.PackageManager;
import android.os.Build;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.PluginRegistry;

/**
 * Created by babariviere on 08/03/18.
 */

class PermissionsHandler implements PluginRegistry.RequestPermissionsResultListener {
    private static Map<Integer, String[]> requestedPermissions = new HashMap<>();
    private static PluginRegistry.Registrar registrar;

    @TargetApi(Build.VERSION_CODES.M)
    static void requestPermissions(String[] permissions, int id) {
        if (requestedPermissions.size() > 0) {
            requestedPermissions.put(id, permissions);
        } else {
            requestedPermissions.put(id, permissions);
            registrar.activity().requestPermissions(permissions, id);
        }
    }

    PermissionsHandler(PluginRegistry.Registrar registrar) {
        PermissionsHandler.registrar = registrar;
    }

    @TargetApi(Build.VERSION_CODES.M)
    @Override
    public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        if (!requestedPermissions.containsKey(requestCode)) {
            return false;
        }

        requestedPermissions.remove(requestCode);
        if (requestedPermissions.keySet().size() > 0) {
            Integer key = (Integer) requestedPermissions.keySet().toArray()[0];
            registrar.activity().requestPermissions(requestedPermissions.get(key), key);
        }

        return false;
    }
}

class Permissions {
    static final int RECV_SMS_ID_REQ = 1;
    static final int SEND_SMS_ID_REQ = 2;
    static final int READ_SMS_ID_REQ = 3;
    static final int READ_CONTACT_ID_REQ = 4;
    private final Activity activity;

    Permissions(Activity activity) {
        this.activity = activity;
    }

    private boolean hasPermission(String permission) {
        return (Build.VERSION.SDK_INT < Build.VERSION_CODES.M
                || activity.checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED);
    }

    private boolean hasPermissions(String[] permissions) {
        for (String perm : permissions) {
            if (!hasPermission(perm)) {
                return false;
            }
        }
        return true;
    }

    boolean checkAndRequestPermission(String[] permissions, int id) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            return true;
        }
        if (!hasPermissions(permissions)) {
            PermissionsHandler.requestPermissions(permissions, id);
            return false;
        }
        return true;
    }
}
