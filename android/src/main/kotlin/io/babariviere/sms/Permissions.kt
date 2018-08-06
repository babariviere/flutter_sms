package io.babariviere.sms

import android.app.Activity
import android.content.pm.PackageManager
import android.os.Build

import io.flutter.plugin.common.PluginRegistry

internal class Permissions(private val activity: Activity) {
    companion object {
        val RECV_SMS_ID_REQ = 1
        val SEND_SMS_ID_REQ = 2
    }

    private fun hasPermission(permission: String): Boolean {
        return Build.VERSION.SDK_INT < Build.VERSION_CODES.M || activity.checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED
    }

    private fun hasPermissions(permissions: Array<String>): Boolean {
        for (perm in permissions) {
            if (!hasPermission(perm)) {
                return false
            }
        }
        return true
    }

    fun checkAndRequestPermission(permissions: Array<String>, id: Int): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            return true
        }
        if (!hasPermissions(permissions)) {
            activity.requestPermissions(permissions, id)
            return false
        }
        return true
    }
}
