package world.verifi.app

import android.content.Context
import io.flutter.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

class VeriFiPlugin: FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    companion object {
        private const val CHANNEL = "world.verifi.app"
        private const val TAG = "VeriFiPlugin"
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler(this)
        context = binding.applicationContext
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startNetworkMonitor" -> {
                Log.d(TAG, "Starting network monitor")
                NetworkMonitorService.startService(context)
                result.success(null)
            }

            "stopNetworkMonitor" -> {
                Log.d(TAG, "Stopping network monitor")
                NetworkMonitorService.stopService(context)
                result.success(null)
            }

            else -> {
                result.notImplemented()
            }
        }
    }
}