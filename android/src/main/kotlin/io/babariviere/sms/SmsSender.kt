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

class SmsSender(private val registrar: Registrar) : MethodCallHandler {
    companion object {
        private val permissionsList: Array<String> = arrayOf(Manifest.permission.SEND_SMS, Manifest.permission.READ_PHONE_STATE)
    }

    override fun onMethodCall(call: MethodCall?, result: MethodChannel.Result?) {
        when {
            call?.method.equals("send") -> {
                val address = call?.argument<String>("address")
                val body = call?.argument<String>("body")
                val sentId = call?.argument<Int>("sentId")
                when {
                    address == null -> result?.error("#02", "missing argument 'address'", null)
                    body == null -> result?.error("#02", "missing argument 'body'", null)
                    else -> {
                        send(result, sentId, address, body);
                    }
                }
            }
            call?.method.equals("permissions") -> result?.success(permissionsList)
            else -> result?.notImplemented()
        }
    }

    private fun send(result: MethodChannel.Result?, sentId: Int?, address: String, body: String) {
        val sentIntent = Intent("SMS_SENT")
        sentIntent.putExtra("sentId", sentId)
        val sentPendingIntent = PendingIntent.getBroadcast(registrar.context(), 0, sentIntent, PendingIntent.FLAG_UPDATE_CURRENT)

        val deliveredIntent = Intent("SMS_DELIVERED")
        deliveredIntent.putExtra("sentId", sentId)
        val deliveredPendingIntent = PendingIntent.getBroadcast(registrar.context(), UUID.randomUUID().hashCode(), deliveredIntent, PendingIntent.FLAG_UPDATE_CURRENT)

        val sms = SmsManager.getDefault()
        sms.sendTextMessage(address, null, body, sentPendingIntent, deliveredPendingIntent)
        result?.success(null)
    }

}