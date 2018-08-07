package io.babariviere.sms

import android.Manifest
import android.app.PendingIntent
import android.content.Intent
import android.content.pm.PackageManager
import android.telephony.SmsManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.plugin.common.PluginRegistry.RequestPermissionsResultListener
import java.util.*

class SmsSenderHandler(
        private val registrar: Registrar,
        private val result: MethodChannel.Result?,
        private val address: String,
        private val body: String,
        private val sentId: Int?
) : RequestPermissionsResultListener {
    private val permissionsList: Array<String> = arrayOf(Manifest.permission.SEND_SMS, Manifest.permission.READ_PHONE_STATE)

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>?, grantResults: IntArray?): Boolean {
        if (requestCode != Permissions.SEND_SMS_ID_REQ) {
            return false
        }
        if (grantResults == null) return false
        var isOk = true
        grantResults.forEach { result ->
            if (result != PackageManager.PERMISSION_GRANTED) isOk = false
        }
        if (isOk) {
            this.send()
        } else {
            result?.error("#01", "permission denied for sending sms", null)
        }
        return isOk
    }

    internal fun handle(permissions: Permissions) {
        if (permissions.checkAndRequestPermission(permissionsList, Permissions.SEND_SMS_ID_REQ)) {
            this.send()
        }
    }

    private fun send() {
        val sentIntent = Intent("SMS_SENT")
        sentIntent.putExtra("sentId", this.sentId)
        val sentPendingIntent = PendingIntent.getBroadcast(registrar.context(), 0, sentIntent, PendingIntent.FLAG_UPDATE_CURRENT)

        val deliveredIntent = Intent("SMS_DELIVERED")
        deliveredIntent.putExtra("sentId", this.sentId)
        val deliveredPendingIntent = PendingIntent.getBroadcast(registrar.context(), UUID.randomUUID().hashCode(), deliveredIntent, PendingIntent.FLAG_UPDATE_CURRENT)

        val sms = SmsManager.getDefault()
        sms.sendTextMessage(this.address, null, this.body, sentPendingIntent, deliveredPendingIntent)
        this.result?.success(null)
    }

}

class SmsSender(private val registrar: Registrar) : MethodCallHandler {
    private val permissions: Permissions = Permissions(this.registrar.activity())

    override fun onMethodCall(call: MethodCall?, result: MethodChannel.Result?) {
        if (call?.method.equals("send")) {
            val address = call?.argument<String>("address")
            val body = call?.argument<String>("body")
            val sentId = call?.argument<Int>("sentId")
            when {
                address == null -> result?.error("#02", "missing argument 'address'", null)
                body == null -> result?.error("#02", "missing argument 'body'", null)
                else -> {
                    val handler = SmsSenderHandler(this.registrar, result, address, body, sentId)
                    this.registrar.addRequestPermissionsResultListener(handler)
                    handler.handle(permissions)
                }
            }
        } else {
            result?.notImplemented()
        }
    }

}