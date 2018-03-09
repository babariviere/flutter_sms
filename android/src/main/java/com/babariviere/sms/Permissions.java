package com.babariviere.sms;

import android.app.Activity;
import android.content.pm.PackageManager;
import android.os.Build;

/**
 * Created by babariviere on 08/03/18.
 */


class Permissions {
  static final int RECV_SMS_ID_REQ = 1;
  static final int SEND_SMS_ID_REQ = 2;
  static final int READ_SMS_ID_REQ = 3;
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
      activity.requestPermissions(permissions, id);
      return false;
    }
    return true;
  }
}
