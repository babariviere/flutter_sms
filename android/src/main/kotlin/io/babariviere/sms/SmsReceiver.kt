package io.babariviere.sms

import android.Manifest
import android.annotation.TargetApi
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Build
import android.provider.Telephony
import android.telephony.SmsMessage
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.plugin.common.PluginRegistry.RequestPermissionsResultListener
import org.json.JSONObject
import java.util.*

class SmsReceiver(private val registrar: Registrar) : EventChannel.StreamHandler, RequestPermissionsResultListener {
    private var receiver: BroadcastReceiver? = null
    private var sink: EventSink? = null
    private val permissions: Permissions = Permissions(registrar.activity())
    private val permissionsList: Array<String> = arrayOf(Manifest.permission.RECEIVE_SMS, Manifest.permission.READ_SMS)

    override fun onListen(arguments: Any?, events: EventSink?) {
        this.registrar.addRequestPermissionsResultListener(this)
        this.receiver = createReceiver(events)
        this.registrar.context().registerReceiver(receiver, IntentFilter(Telephony.Sms.Intents.SMS_RECEIVED_ACTION))
        this.sink = events
        this.permissions.checkAndRequestPermission(permissionsList, Permissions.RECV_SMS_ID_REQ);

    }

    override fun onCancel(p0: Any?) {
        this.registrar.context().unregisterReceiver(this.receiver)
        this.receiver = null
    }

    @TargetApi(Build.VERSION_CODES.KITKAT)
    private fun readMessages(intent: Intent): Array<SmsMessage> {
        return Telephony.Sms.Intents.getMessagesFromIntent(intent)
    }

    private fun createReceiver(events: EventSink?): BroadcastReceiver {
        return object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                val messages = readMessages(intent ?: return)
                if (messages.isEmpty()) {
                    return
                }

                val body = messages.toList().fold(StringBuilder()) { dest, message ->
                    dest.append(message.messageBody)
                    dest
                }.toString()

                val json = JSONObject().apply {

                    put("address", messages[0].originatingAddress)
                    put("body", body)
                    put("date", Date().time)
                    put("date_sent", messages[0].timestampMillis)
                    put("thread_id", TelephonyCompat.getOrCreateThreadId(context
                            ?: return, messages[0].originatingAddress))
                }

                events?.success(json)
            }
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>?, grantResults: IntArray?): Boolean {
        if (requestCode != Permissions.RECV_SMS_ID_REQ) {
            return false
        }
        if (grantResults == null) return false
        var isOk = true
        grantResults.forEach { result ->
            if (result != PackageManager.PERMISSION_GRANTED) isOk = false
        }
        if (!isOk) this.sink?.endOfStream()
        return isOk
    }
}