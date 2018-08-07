package io.babariviere.sms

import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.JSONMethodCodec
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry.Registrar

class SmsPlugin {
    companion object {
        private const val CHANNEL_RECEIVE = "plugins.babariviere.io/receiveSMS"
        private const val CHANNEL_SEND = "plugins.babariviere.com/sendSMS"
        private const val CHANNEL_STATUS = "plugins.babariviere.com/statusSMS"

        @JvmStatic
        fun registerWith(registrar: Registrar): Unit {
            val receiveChannel = EventChannel(registrar.messenger(), CHANNEL_RECEIVE, JSONMethodCodec.INSTANCE)
            receiveChannel.setStreamHandler(SmsReceiver(registrar))

            val sendChannel = MethodChannel(registrar.messenger(), CHANNEL_SEND, JSONMethodCodec.INSTANCE)
            sendChannel.setMethodCallHandler(SmsSender(registrar))
        }
    }
}
