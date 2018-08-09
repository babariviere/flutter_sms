package com.babariviere.sms.permisions;

import android.app.Activity;
import android.content.pm.PackageManager;
import android.os.Build;

import io.flutter.plugin.common.PluginRegistry;

/**
 * Created by babariviere on 08/03/18.
 */

public class Permissions {
    public static final int RECV_SMS_ID_REQ = 1;
    public static final int SEND_SMS_ID_REQ = 2;
    public static final int READ_SMS_ID_REQ = 3;
    public static final int READ_CONTACT_ID_REQ = 4;
    public static final int BROADCAST_SMS = 5;
    public static final int READ_PHONE_STATE = 6;
    private static final PermissionsRequestHandler requestsListener = new PermissionsRequestHandler();
    private final Activity activity;

    public Permissions(Activity activity) {
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

    public static PluginRegistry.RequestPermissionsResultListener getRequestsResultsListener() {
        return requestsListener;
    }

    public boolean checkAndRequestPermission(String[] permissions, int id) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            return true;
        }
        if (!hasPermissions(permissions)) {
            PermissionsRequestHandler.requestPermissions(
                    new PermissionsRequest(id, permissions, activity)
            );
            return false;
        }
        return true;
    }
}
