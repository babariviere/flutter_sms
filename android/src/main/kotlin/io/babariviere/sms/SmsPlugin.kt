package io.babariviere.sms

import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.PluginRegistry.Registrar

class SmsPlugin {
  companion object {
    private const val CHANNEL_RECV = "plugins.babariviere.io/recvSMS"

    @JvmStatic
    fun registerWith(registrar: Registrar): Unit {
      val receiveChannel = EventChannel(registrar.messenger(), CHANNEL_RECV)
      receiveChannel.setStreamHandler(SmsReceiver(registrar))
    }
  }
}
