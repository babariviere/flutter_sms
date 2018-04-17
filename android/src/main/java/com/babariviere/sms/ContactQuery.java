package com.babariviere.sms;

import android.Manifest;
import android.annotation.TargetApi;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.provider.ContactsContract;

import com.babariviere.sms.permisions.Permissions;

import org.json.JSONException;
import org.json.JSONObject;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.PluginRegistry;

import static io.flutter.plugin.common.PluginRegistry.RequestPermissionsResultListener;

/**
 * Created by babariviere on 10/03/18.
 */

class ContactQueryHandler implements RequestPermissionsResultListener {
    private final String[] permissionsList = new String[]{Manifest.permission.READ_CONTACTS};
    private PluginRegistry.Registrar registrar;
    private MethodChannel.Result result;
    private String contactAddress;

    ContactQueryHandler(PluginRegistry.Registrar registrar, MethodChannel.Result result, String contactAddress) {
        this.registrar = registrar;
        this.result = result;
        this.contactAddress = contactAddress;
    }

    void handle(Permissions permissions) {
        if (permissions.checkAndRequestPermission(permissionsList, Permissions.READ_CONTACT_ID_REQ)) {
            queryContact();
        }
    }

    @TargetApi(Build.VERSION_CODES.HONEYCOMB)
    private void queryContact() {
        Uri uri = Uri.withAppendedPath(ContactsContract.PhoneLookup.CONTENT_FILTER_URI, Uri.encode(this.contactAddress));

        String[] projection = new String[]{
                ContactsContract.PhoneLookup.DISPLAY_NAME,
                ContactsContract.PhoneLookup.PHOTO_URI,
                ContactsContract.PhoneLookup.PHOTO_THUMBNAIL_URI
        };
        JSONObject obj = new JSONObject();
        Cursor cursor = registrar.context().getContentResolver().query(uri, projection, null, null, null);
        if (cursor != null) {
            if (cursor.moveToFirst()) {
                try {
                    obj.put("name", cursor.getString(0));
                    obj.put("photo", cursor.getString(1));
                    obj.put("thumbnail", cursor.getString(2));
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }
            cursor.close();
        }
        result.success(obj);
    }

    @Override
    public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        if (requestCode != Permissions.READ_CONTACT_ID_REQ) {
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
            queryContact();
            return true;
        }
        result.error("#01", "permission denied", null);
        return false;
    }
}

class ContactQuery implements MethodCallHandler {
    private final Permissions permissions;
    private final PluginRegistry.Registrar registrar;

    ContactQuery(PluginRegistry.Registrar registrar) {
        this.registrar = registrar;
        permissions = new Permissions(registrar.activity());
    }

    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        if (!call.method.equals("getContact")) {
            result.notImplemented();
        } else if (!call.hasArgument("address")) {
            result.error("#02", "missing argument 'address'", null);
        } else {
            String contactAddress = call.argument("address");
            ContactQueryHandler handler = new ContactQueryHandler(registrar, result, contactAddress);
            this.registrar.addRequestPermissionsResultListener(handler);
            handler.handle(permissions);
        }
    }
}
