package world.verifi.app

import android.Manifest
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.net.wifi.WifiManager
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.concurrent.futures.CallbackToFutureAdapter
import androidx.core.app.ActivityCompat
import androidx.work.Data
import androidx.work.ForegroundInfo
import androidx.work.ListenableWorker
import androidx.work.WorkerParameters
import com.google.common.util.concurrent.ListenableFuture
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.engine.loader.FlutterLoader
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.view.FlutterCallbackInformation
import world.verifi.app.VeriFiWifiSuggestions.Companion.transformWifisToSuggestions
import java.util.concurrent.Executors


class BackgroundWorker(
  private val ctx: Context,
  private val workerParameters: WorkerParameters
) :
  ListenableWorker(ctx, workerParameters), MethodChannel.MethodCallHandler {

  companion object {
    private const val TAG = "GeofenceWorker"

    const val CALLBACK_HANDLE = "world.verifi.app.CALLBACK_HANDLE"
    const val GF_FENCE_IDS = "world.verifi.app.GF_FENCE_IDS"
    const val GF_LAT = "world.verifi.app.GF_LAT"
    const val GF_LNG = "world.verifi.app.GF_LNG"
    const val BACKGROUND_CHANNEL_NAME = "world.verifi.app/background_channel"
    const val BACKGROUND_CHANNEL_INITIALIZED = "initialized"
    const val BACKGROUND_CHANNEL_ADD_SUGGESTIONS = "add_suggestions"
    const val BACKGROUND_CHANNEL_REMOVE_SUGGESTIONS = "remove_suggestions"
    private val flutterLoader = FlutterLoader()
  }

  private lateinit var backgroundChannel: MethodChannel
  private val executor = Executors.newSingleThreadExecutor()

  private var engine: FlutterEngine? = null
  private val callbackHandle
    get() = workerParameters.inputData.getLong(CALLBACK_HANDLE, -1L)
  private val fenceIds
    get() = workerParameters.inputData.getStringArray(GF_FENCE_IDS)
  private val lat
    get() = workerParameters.inputData.getDouble(GF_LAT, -1.0)
  private val lng
    get() = workerParameters.inputData.getDouble(GF_LNG, -1.0)

  private val wifiManager =
    applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager

  private lateinit var futureCompleter: CallbackToFutureAdapter.Completer<Result>

  private val futureCallback = object : MethodChannel.Result {
    override fun success(result: Any?) {
      val isSuccess = result?.let { it as Boolean? } == true
      if (isSuccess) futureCompleter.set(Result.success()) else futureCompleter.set(
        Result.retry()
      )
      stopEngine()
    }

    override fun error(
      errorCode: String,
      errorMessage: String?,
      errorDetails: Any?
    ) {
      Log.e(TAG, "$errorCode, $errorMessage")
      stopEngine()
      futureCompleter.set(
        Result.failure(
          Data.Builder().putString("error_code", errorCode)
            .putString("error_msg", errorMessage).build()
        )
      )
    }

    override fun notImplemented() {
      stopEngine()
      futureCompleter.set(Result.failure())
    }
  }

  private val connectionStatusListener =
    WifiManager.SuggestionConnectionStatusListener { suggestion, reason ->
      if (reason == WifiManager.STATUS_SUGGESTION_CONNECTION_FAILURE_AUTHENTICATION) {
        Log.e(
          TAG,
          "Network connection to ${suggestion.ssid} failed due to invalid credentials."
        )
        val status = wifiManager.removeNetworkSuggestions(listOf(suggestion))
        if (status != WifiManager.STATUS_NETWORK_SUGGESTIONS_SUCCESS) {
          Log.e(TAG, "Network connection removal failed. Status code $status")
        }
      }
    }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      BACKGROUND_CHANNEL_INITIALIZED -> {
        Log.d(TAG, "Background channel initialized called")
        Log.d(TAG, "Input param lat: $lat")
        Log.d(TAG, "Input param lng: $lng")
        backgroundChannel.invokeMethod(
          "sendCoordinates", // this can be whatever
          mapOf(
            CALLBACK_HANDLE to callbackHandle,
            GF_LAT to lat,
            GF_LNG to lng,
          ),
          futureCallback,
        )
        Log.d(TAG, "We made it here")
      }
      BACKGROUND_CHANNEL_ADD_SUGGESTIONS -> {
        Log.d(TAG, "Add suggestions called")
        Log.d(TAG, "Add suggestions args: ${call.arguments}")
        val args = call.arguments<List<List<String>>?>()
        if (args.isNullOrEmpty()) {
          futureCallback.error(
            "no-args",
            "No arguments passed to add suggestions",
            null,
          )
          return
        }
        val suggestions = transformWifisToSuggestions(args)
        if (ActivityCompat.checkSelfPermission(
            ctx,
            Manifest.permission.ACCESS_FINE_LOCATION,
          ) != PackageManager.PERMISSION_GRANTED
        ) {
          return
        }
        wifiManager.addSuggestionConnectionStatusListener(
          executor,
          connectionStatusListener
        )
        val status = wifiManager.addNetworkSuggestions(suggestions)
        if (status != WifiManager.STATUS_NETWORK_SUGGESTIONS_SUCCESS) {
          Log.e(TAG, "Failed to add network suggestions: $status")
          futureCallback.error(
            status.toString(),
            "Failed to add network suggestion",
            null
          )
          return
        }
        futureCallback.success(true)
      }

      BACKGROUND_CHANNEL_REMOVE_SUGGESTIONS -> {
        Log.d(TAG, "Remove suggestions called")
      }

      else -> result.notImplemented()
    }
  }

  override fun onStopped() {
    stopEngine()
    super.onStopped()
  }

  private fun stopEngine() {
    engine?.destroy()
    engine = null
  }

  override fun startWork(): ListenableFuture<Result> {
    Log.d(TAG, "startWork called")
    return CallbackToFutureAdapter.getFuture { completer ->
      futureCompleter = completer
      engine = FlutterEngine(applicationContext)
      if (!flutterLoader.initialized()) {
        flutterLoader.startInitialization(applicationContext)
      }
      flutterLoader.ensureInitializationCompleteAsync(
        applicationContext, null, Handler(Looper.getMainLooper())
      ) {
        val callbackHandle =
          applicationContext.getSharedPreferences(
            MainActivity.SHARED_PREFERENCES_KEY,
            Context.MODE_PRIVATE
          ).getLong(MainActivity.DISPATCHER_CALLBACK_HANDLE_KEY, -1L)
        val callbackInfo =
          FlutterCallbackInformation.lookupCallbackInformation(callbackHandle)
        val dartBundlePath = flutterLoader.findAppBundlePath()
        engine?.let { engine ->
          backgroundChannel =
            MethodChannel(engine.dartExecutor, BACKGROUND_CHANNEL_NAME)
          backgroundChannel.setMethodCallHandler(this)
          engine.dartExecutor.executeDartCallback(
            DartExecutor.DartCallback(
              applicationContext.assets,
              dartBundlePath,
              callbackInfo
            )
          )
        }
      }
      futureCallback
    }
  }

  override fun getForegroundInfoAsync(): ListenableFuture<ForegroundInfo> {
    return CallbackToFutureAdapter.getFuture {
      it.set(
        ForegroundInfo(
          Notifications.CHANNEL_ID_VERIFI_FOREGROUND_SERVICE.hashCode(),
          Notifications.buildForegroundNotification(applicationContext)
        )
      )
    }
  }

  private fun setUpConnectionReceiver() {
    // Optional (Wait for post connection broadcast to one of your suggestions)
    val intentFilter =
      IntentFilter(WifiManager.ACTION_WIFI_NETWORK_SUGGESTION_POST_CONNECTION)

    val broadcastReceiver = object : BroadcastReceiver() {
      override fun onReceive(context: Context, intent: Intent) {
        if (!intent.action.equals(WifiManager.ACTION_WIFI_NETWORK_SUGGESTION_POST_CONNECTION)) {
          return
        }
      }
    }
    ctx.registerReceiver(broadcastReceiver, intentFilter)

  }
}

