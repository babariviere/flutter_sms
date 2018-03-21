package com.babariviere.sms;

import android.Manifest;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.net.Uri;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Date;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

import static io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import static io.flutter.plugin.common.MethodChannel.Result;
import static io.flutter.plugin.common.PluginRegistry.RequestPermissionsResultListener;

/**
 * Created by babariviere on 09/03/18.
 */

enum SmsQueryRequest {
  Inbox,
  Sent,
  Draft;


  Uri toUri() {
    if (this == Inbox) {
      return Uri.parse("content://sms/inbox");
    } else if (this == Sent) {
      return Uri.parse("content://sms/sent");
    } else {
      return Uri.parse("content://sms/draft");
    }
  }
}

class SmsQuery implements MethodCallHandler, RequestPermissionsResultListener {
  private final PluginRegistry.Registrar registrar;
  private final Permissions permissions;
  private final String[] permissionsList = new String[]{Manifest.permission.READ_SMS};
  private MethodChannel.Result result;

  private SmsQueryRequest request;
  private int start = 0;
  private int count = -1;
  private int threadId = -1;
  private String address = null;

  SmsQuery(PluginRegistry.Registrar registrar) {
    this.registrar = registrar;
    this.permissions = new Permissions(registrar.activity());
    registrar.addRequestPermissionsResultListener(this);
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    this.result = result;
    start = 0;
    count = -1;
    threadId = -1;
    address = null;
    switch (call.method) {
      case "getInbox":
        request = SmsQueryRequest.Inbox;
        break;
      case "getSent":
        request = SmsQueryRequest.Sent;
        break;
      case "getDraft":
        request = SmsQueryRequest.Draft;
        break;
      default:
        result.notImplemented();
        return;
    }
    if (call.hasArgument("start")) {
      start = call.argument("start");
    }
    if (call.hasArgument("count")) {
      count = call.argument("count");
    }
    if (call.hasArgument("thread_id")) {
      threadId = call.argument("thread_id");
    }
    if (call.hasArgument("address")) {
      address = call.argument("address");
    }
    if (permissions.checkAndRequestPermission(permissionsList, Permissions.READ_SMS_ID_REQ)) {
      querySms();
    }
  }

  private JSONObject readSms(Cursor cursor) {
    JSONObject res = new JSONObject();
    for (int idx = 0; idx < cursor.getColumnCount(); idx++) {
      try {
        if (cursor.getColumnName(idx).equals("address") || cursor.getColumnName(idx).equals("body")) {
          res.put(cursor.getColumnName(idx), cursor.getString(idx));
        }
        else if (cursor.getColumnName(idx).equals("date") || cursor.getColumnName(idx).equals("date_sent")) {
          res.put(cursor.getColumnName(idx), cursor.getLong(idx));
        }
        else {
          res.put(cursor.getColumnName(idx), cursor.getInt(idx));
        }
      } catch (JSONException e) {
        e.printStackTrace();
      }
    }
    return res;
  }

  private void querySms() {
    ArrayList<JSONObject> list = new ArrayList<>();
    Cursor cursor = registrar.context().getContentResolver().query(this.request.toUri(), null, null, null, null);
    if (cursor == null) {
      result.error("#01", "permission denied", null);
      return;
    }
    if (!cursor.moveToFirst()) {
      cursor.close();
      result.success(list);
      return;
    }
    do {
      JSONObject obj = readSms(cursor);
      try {
        if (threadId >= 0 && obj.getInt("thread_id") != threadId) {
          continue;
        }
        if (address != null && !obj.getString("address").equals(address)) {
          continue;
        }
      } catch (JSONException e) {
        e.printStackTrace();
      }
      if (start > 0) {
        start--;
        continue;
      }
      list.add(obj);
      if (count > 0) {
        count--;
      }
    } while (cursor.moveToNext() && count != 0);
    cursor.close();
    result.success(list);
  }

  @Override
  public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
    if (requestCode != Permissions.READ_SMS_ID_REQ) {
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
      querySms();
      return true;
    }
    result.error("#01", "permission denied", null);
    return false;
  }
}
