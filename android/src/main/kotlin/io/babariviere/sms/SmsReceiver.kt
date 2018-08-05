package io.babariviere.sms

import android.annotation.TargetApi
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Telephony
import android.telephony.SmsMessage
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.PluginRegistry.Registrar
import org.json.JSONObject
import java.util.*

class SmsReceiver(private val registrar: Registrar) : EventChannel.StreamHandler {
    private var receiver: BroadcastReceiver? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        this.receiver = createReceiver(events)
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    override fun onCancel(p0: Any?) {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    @TargetApi(Build.VERSION_CODES.KITKAT)
    private fun readMessages(intent: Intent): Array<SmsMessage> {
        return Telephony.Sms.Intents.getMessagesFromIntent(intent);
    }

    private fun createReceiver(events: EventChannel.EventSink?): BroadcastReceiver {
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