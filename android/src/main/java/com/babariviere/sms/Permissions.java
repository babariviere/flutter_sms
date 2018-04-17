package com.babariviere.sms;

import android.annotation.TargetApi;
import android.app.Activity;
import android.content.pm.PackageManager;
import android.os.Build;

import java.util.Queue;
import java.util.concurrent.LinkedBlockingQueue;

import io.flutter.plugin.common.PluginRegistry;

/**
 * Created by babariviere on 08/03/18.
 */

class PermissionsRequest {
    private int id;
    private Activity activity;
    private String[] permissions;

    PermissionsRequest(int id, String[] permissions, Activity activity) {
        this.id = id;
        this.permissions = permissions;
        this.activity = activity;
    }

    int getId() {
        return this.id;
    }

    @TargetApi(Build.VERSION_CODES.M)
    void execute() {
        this.activity.requestPermissions(this.permissions, this.id);
    }
}

class PermissionsRequestHandler implements PluginRegistry.RequestPermissionsResultListener {
    private static Queue<PermissionsRequest> requests = new LinkedBlockingQueue<>();
    private static boolean isRequesting = false;

    @TargetApi(Build.VERSION_CODES.M)
    static void requestPermissions(PermissionsRequest permissionsRequest) {
        if (!isRequesting) {
            isRequesting = true;
            permissionsRequest.execute();
        } else {
            requests.add(permissionsRequest);
        }
    }

    @TargetApi(Build.VERSION_CODES.M)
    @Override
    public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        isRequesting = requests.size() > 0;
        if (isRequesting) {
            requests.poll().execute();
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
            PermissionsRequestHandler.requestPermissions(
                    new PermissionsRequest(id, permissions, activity)
            );
            return false;
        }
        return true;
    }
}
