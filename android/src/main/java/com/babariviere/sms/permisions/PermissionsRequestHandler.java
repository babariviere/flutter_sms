package com.babariviere.sms.permisions;

import android.annotation.TargetApi;
import android.os.Build;

import java.util.Queue;
import java.util.concurrent.LinkedBlockingQueue;

import io.flutter.plugin.common.PluginRegistry;

/**
 * Created by Joan Pablo on 4/17/2018.
 */

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
