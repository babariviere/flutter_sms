package io.babariviere.sms

import android.Manifest
import android.annotation.TargetApi
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.provider.Telephony
import android.telephony.SmsMessage
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry.Registrar
import org.json.JSONObject
import java.util.*

class SmsReceiver(private val registrar: Registrar) : EventChannel.StreamHandler, MethodChannel.MethodCallHandler {
    companion object {
        private val permissionsList: Array<String> = arrayOf(Manifest.permission.RECEIVE_SMS, Manifest.permission.READ_SMS)
    }

    private var receiver: BroadcastReceiver? = null
    private var sink: EventSink? = null

    override fun onListen(arguments: Any?, events: EventSink?) {
        this.receiver = createReceiver(events)
        this.registrar.context().registerReceiver(receiver, IntentFilter(Telephony.Sms.Intents.SMS_RECEIVED_ACTION))
        this.sink = events

    }

    override fun onCancel(p0: Any?) {
        this.registrar.context().unregisterReceiver(this.receiver)
        this.receiver = null
        this.sink = null
    }

    override fun onMethodCall(call: MethodCall?, result: MethodChannel.Result?) {
        if (call?.method.equals("permissions")) {
            result?.success(permissionsList)
        } else {
            result?.notImplemented()
        }
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

}