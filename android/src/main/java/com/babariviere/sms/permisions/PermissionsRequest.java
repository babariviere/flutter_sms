package com.babariviere.sms.permisions;

import android.annotation.TargetApi;
import android.app.Activity;
import android.os.Build;

/**
 * Created by Joan Pablo on 4/17/2018.
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
