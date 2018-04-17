package com.babariviere.sms;


import android.Manifest;
import android.annotation.TargetApi;
import android.content.pm.PackageManager;
import android.content.res.AssetFileDescriptor;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.provider.ContactsContract;

import com.babariviere.sms.permisions.Permissions;

import java.io.IOException;
import java.io.InputStream;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.PluginRegistry;

import static io.flutter.plugin.common.PluginRegistry.RequestPermissionsResultListener;

/**
 * Created by joanpablo on 18/03/18.
 */

class ContactPhotoQueryHandler implements RequestPermissionsResultListener {
  private final PluginRegistry.Registrar registrar;
  private final String[] permissionsList = new String[]{Manifest.permission.READ_CONTACTS};
  private MethodChannel.Result result;
  private String photoUri;
  private boolean fullSize;

  ContactPhotoQueryHandler(PluginRegistry.Registrar registrar, MethodChannel.Result result, String photoUri, boolean fullSize) {
    this.registrar = registrar;
    this.result = result;
    this.photoUri = photoUri;
    this.fullSize = fullSize;
  }

  void handle(Permissions permissions) {
    if (permissions.checkAndRequestPermission(permissionsList, Permissions.READ_CONTACT_ID_REQ)) {
      if (fullSize) {
        queryContactPhoto();
      } else {
        queryContactThumbnail();
      }
    }
  }

  @TargetApi(Build.VERSION_CODES.ECLAIR)
  private void queryContactThumbnail() {
    Uri uri = Uri.withAppendedPath(ContactsContract.AUTHORITY_URI, photoUri);
    Cursor cursor = registrar.context().getContentResolver().query(uri,
        new String[]{ContactsContract.CommonDataKinds.Photo.PHOTO}, null, null, null);
    if (cursor == null) {
      return;
    }
    try {
      if (cursor.moveToFirst()) {
        result.success(cursor.getBlob(0));
      }
    } finally {
      cursor.close();
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

class ContactPhotoQuery implements MethodCallHandler {
    private final Permissions permissions;
  private final PluginRegistry.Registrar registrar;

    ContactPhotoQuery(PluginRegistry.Registrar registrar) {
        this.registrar = registrar;
        permissions = new Permissions(registrar.activity());
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
      String photoUri = call.argument("photoUri");
        boolean fullSize = call.hasArgument("fullSize") && (boolean) call.argument("fullSize");
      ContactPhotoQueryHandler handler = new ContactPhotoQueryHandler(registrar, result, photoUri, fullSize);
      this.registrar.addRequestPermissionsResultListener(handler);
      handler.handle(permissions);
    }
}