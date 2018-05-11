package com.babariviere.sms;

import android.Manifest;
import android.annotation.TargetApi;
import android.content.ContentResolver;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.provider.ContactsContract;

import com.babariviere.sms.permisions.Permissions;

import org.json.JSONArray;
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

    private void queryUserProfile() {
        try {
            JSONObject obj = getProfileObject();
            if (obj != null) {
                obj.put("addresses", getProfileAddresses(obj.getString("id")));
            }
            result.success(obj);

        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    @TargetApi(Build.VERSION_CODES.ICE_CREAM_SANDWICH)
    private JSONObject getProfileObject() {
        JSONObject obj = null;

        String[] projection = new String[]{
                ContactsContract.Profile._ID,
                ContactsContract.Profile.DISPLAY_NAME,
                ContactsContract.Profile.PHOTO_URI,
                ContactsContract.Profile.PHOTO_THUMBNAIL_URI,
        };

        Cursor cursor = getContentResolver().query(ContactsContract.Profile.CONTENT_URI, projection, null, null, null);
        if (cursor != null) {
            if (cursor.moveToFirst()) {
                obj = new JSONObject();
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

        return obj;
    }


    @TargetApi(Build.VERSION_CODES.HONEYCOMB)
    private JSONArray getProfileAddresses(String profileId) {
        JSONArray addressCollection = new JSONArray();
        if (profileId != null) {
            Uri contentUri = Uri.withAppendedPath(ContactsContract.Contacts.CONTENT_URI, profileId);
            Uri uri = Uri.withAppendedPath(contentUri, ContactsContract.Contacts.Entity.CONTENT_DIRECTORY);

            String[] projection = new String[]{
                    ContactsContract.Contacts.Entity.DATA1,
                    ContactsContract.Contacts.Entity.MIMETYPE
            };

            Cursor cursor = getContentResolver().query(uri, projection, null, null, null);

            if (cursor != null) {
                cursor.moveToFirst();
                do {
                    if (cursor.getString(1).equals("vnd.android.cursor.item/phone_v2")) {
                        addressCollection.put(cursor.getString(0));
                    }
                }
                while (cursor.moveToNext());
                cursor.close();
            }
        }

        return addressCollection;
    }

    private ContentResolver getContentResolver() {
        return registrar.context().getContentResolver();
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