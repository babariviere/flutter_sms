package com.babariviere.sms;


import android.Manifest;
import android.annotation.TargetApi;
import android.content.pm.PackageManager;
import android.content.res.AssetFileDescriptor;
import android.net.Uri;
import android.os.Build;
import android.provider.ContactsContract;

import java.io.IOException;
import java.io.InputStream;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.PluginRegistry;

import static io.flutter.plugin.common.PluginRegistry.RequestPermissionsResultListener;

/**
 * Created by babariviere on 10/03/18.
 */

class ContactPhotoQuery implements MethodCallHandler, RequestPermissionsResultListener {
    private final String[] permissionsList = new String[]{Manifest.permission.READ_CONTACTS};
    private final Permissions permissions;
    private final PluginRegistry.Registrar registrar;
    private MethodChannel.Result result;
    private String photoUri;

    ContactPhotoQuery(PluginRegistry.Registrar registrar) {
        this.registrar = registrar;
        permissions = new Permissions(registrar.activity());
        registrar.addRequestPermissionsResultListener(this);
    }

    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        if (!call.method.equals("getContactPhoto")) {
            result.notImplemented();
            return;
        }
        if (!call.hasArgument("photoUri")) {
            result.error("#02", "missing argument 'photoUri'", null);
            return;
        }

        photoUri = call.argument("photoUri");
        this.result = result;
        if (permissions.checkAndRequestPermission(permissionsList, Permissions.READ_CONTACT_ID_REQ)) {
            queryContactPhoto();
        }
    }

    @TargetApi(Build.VERSION_CODES.ECLAIR)
    private void queryContactPhoto() {
        Uri uri = Uri.withAppendedPath(ContactsContract.AUTHORITY_URI, photoUri);

        try {
            AssetFileDescriptor fd = registrar.context().getContentResolver().openAssetFileDescriptor(
                    uri, "r");
            if (fd != null) {
                byte[] bytes = new byte[(int) fd.getLength()];
                InputStream stream = fd.createInputStream();
                stream.read(bytes);
                stream.close();
                result.success(bytes);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
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
            queryContactPhoto();
            return true;
        }
        result.error("#01", "permission denied", null);
        return false;
    }

}