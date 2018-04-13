package com.babariviere.sms;

import android.Manifest;
import android.annotation.TargetApi;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.provider.ContactsContract;

import org.json.JSONException;
import org.json.JSONObject;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

/**
 * Created by Joan Pablo on 4/11/2018.
 */

class UserProfileHandler implements PluginRegistry.RequestPermissionsResultListener {
    private final String[] permissionsList = new String[]{Manifest.permission.READ_CONTACTS};
    private PluginRegistry.Registrar registrar;
    private MethodChannel.Result result;

    UserProfileHandler(PluginRegistry.Registrar registrar, MethodChannel.Result result) {
        this.registrar = registrar;
        this.result = result;
    }

    void handle(Permissions permissions) {
        if (permissions.checkAndRequestPermission(permissionsList, Permissions.READ_CONTACT_ID_REQ)) {
            queryUserProfile();
        }
    }

    @TargetApi(Build.VERSION_CODES.JELLY_BEAN)
    private void queryUserProfile() {
        String[] projection = new String[]{
                ContactsContract.Profile._ID,
                ContactsContract.Profile.DISPLAY_NAME,
                ContactsContract.Profile.PHOTO_URI,
                ContactsContract.Profile.PHOTO_THUMBNAIL_URI,
        };

        JSONObject obj = new JSONObject();
        Cursor cursor = registrar.context().getContentResolver().query(
                ContactsContract.Profile.CONTENT_URI, projection, null, null, null);
        if (cursor != null) {
            if (cursor.moveToFirst()) {
                try {
                    obj.put("id", cursor.getString(0));
                    obj.put("name", cursor.getString(1));
                    obj.put("photo", cursor.getString(2));
                    obj.put("thumbnail", cursor.getString(3));
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }
            cursor.close();
        }

        if (!obj.isNull("id")) {
            try {
                Uri contentUri = Uri.withAppendedPath(ContactsContract.Contacts.CONTENT_URI, obj.getString("id"));
                Uri uri = Uri.withAppendedPath(contentUri, ContactsContract.Contacts.Entity.CONTENT_DIRECTORY);

                projection = new String[]{
                        ContactsContract.Contacts.Entity.RAW_CONTACT_ID,
                        ContactsContract.Contacts.Entity.DATA1,
                        ContactsContract.Contacts.Entity.MIMETYPE
                };

                cursor = registrar
                        .context()
                        .getContentResolver()
                        .query(
                                uri,
                                projection,
                                null,
                                null,
                                null
                        );
                if (cursor != null) {
                    while (cursor.moveToNext()) {
                        System.out.println(cursor.getString(1) + " - " + cursor.getString(2));
                    }
                    cursor.close();
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }

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
            queryUserProfile();
            return true;
        }
        result.error("#01", "permission denied", null);
        return false;
    }
}

class UserProfileProvider implements MethodChannel.MethodCallHandler {
    private final Permissions permissions;
    private final PluginRegistry.Registrar registrar;

    UserProfileProvider(PluginRegistry.Registrar registrar) {
        this.registrar = registrar;
        permissions = new Permissions(registrar.activity());
    }

    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        if (!call.method.equals("getUserProfile")) {
            result.notImplemented();
        } else {
            getUserProfile(result);
        }
    }

    private void getUserProfile(MethodChannel.Result result) {
        UserProfileHandler handler = new UserProfileHandler(registrar, result);
        this.registrar.addRequestPermissionsResultListener(handler);
        handler.handle(permissions);
    }
}