package io.babariviere.sms

import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

class Permissions(private val registrar: PluginRegistry.Registrar): MethodChannel.MethodCallHandler, EventChannel.StreamHandler {
    private var sink: EventChannel.EventSink? = null

    override fun onMethodCall(call: MethodCall?, result: MethodChannel.Result?) {
    }

    override fun onListen(args: Any?, sink: EventChannel.EventSink?) {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    override fun onCancel(args: Any?) {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }
}