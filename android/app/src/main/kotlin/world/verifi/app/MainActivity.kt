package world.verifi.app

import android.annotation.SuppressLint
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.util.Log
import com.google.android.gms.location.Geofence
import com.google.android.gms.location.GeofencingClient
import com.google.android.gms.location.GeofencingRequest
import com.google.android.gms.location.LocationServices
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity(), MethodChannel.MethodCallHandler {
  private val channelName = "world.verifi.app/channel"
  private lateinit var geofencingClient: GeofencingClient

  companion object {
    private const val TAG = "MainActivity"
    const val SHARED_PREFERENCES_KEY = "world.verifi.app.shared_preferences_key"
    const val DISPATCHER_CALLBACK_HANDLE_KEY = "dispatcherCallbackHandle"
    const val CALLBACK_HANDLE_KEY = "callbackHandleKey"

    @JvmStatic
    fun registerGeofence(
        ctx: Context,
        geofencingClient: GeofencingClient,
        args: ArrayList<*>,
        result: MethodChannel.Result?
    ) {
      val geofences = mutableListOf<Geofence>()
      val callbackHandle = args[0] as Long
      val gfs = args[1] as List<List<*>>
      for (gf in gfs) {
        val id = gf[0] as String
        val lat = gf[1] as Double
        val lng = gf[2] as Double
        val radius = 100f
        val geofence =
            Geofence.Builder()
                .setRequestId(id)
                .setCircularRegion(lat, lng, radius)
                .setTransitionTypes(
                    Geofence.GEOFENCE_TRANSITION_DWELL or Geofence.GEOFENCE_TRANSITION_ENTER
                )
                .setLoiteringDelay(10000)
                .setExpirationDuration(Geofence.NEVER_EXPIRE)
                .build()
        geofences.add(geofence)
      }
      Log.d(TAG, "Geofences: $geofences")
      geofencingClient.addGeofences(
              getGeofencingRequest(geofences.toList()),
              getGeofencePendingIndent(ctx, callbackHandle)
          )
          .run {
            addOnSuccessListener {
              Log.d(TAG, "Geofence registered successfully!")
              result?.success(true)
            }
            addOnFailureListener {
              Log.e(TAG, "Failed to add geofence: $it")
              result?.error(it.toString(), it.message, it.localizedMessage)
            }
          }
    }

    @JvmStatic
    private fun getGeofencingRequest(
        geofences: List<Geofence>,
    ): GeofencingRequest {
      return GeofencingRequest.Builder().apply { addGeofences(geofences) }.build()
    }

    @JvmStatic
    private fun getGeofencePendingIndent(
        context: Context,
        callbackHandle: Long,
    ): PendingIntent {
      val intent =
          Intent(context, GeofenceBroadcastReceiver::class.java)
              .putExtra(CALLBACK_HANDLE_KEY, callbackHandle)
      return PendingIntent.getBroadcast(context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT)
    }
  }

  override fun onCreate(savedInstanceState: Bundle?) {
    geofencingClient = GeofencingClient(this)
    super.onCreate(savedInstanceState)
  }

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    geofencingClient = LocationServices.getGeofencingClient(this)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
        .setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    val args = call.arguments() as ArrayList<*>?
    when (call.method) {
      "initialize" -> {
        if (args.isNullOrEmpty()) {
          result.error("no-args", "Invalid arguments to initialize", null)
          return
        }
        val dispatcherHandle = args[0] as Long
        initializeCallbackHandle(this, dispatcherHandle)
        Notifications.createNotificationChannel(this)
        result.success(true)
      }
      "registerGeofence" -> {
        if (args.isNullOrEmpty()) {
          result.error("no-args", "Invalid arguments to registerGeofence", null)
          return
        }
        registerGeofence(this, geofencingClient, args, result)
      }
      else -> result.notImplemented()
    }
  }

  private fun initializeCallbackHandle(ctx: Context, callbackHandle: Long) {
    Log.d(TAG, "Saving callback handle")
    ctx.getSharedPreferences(SHARED_PREFERENCES_KEY, Context.MODE_PRIVATE)
        .edit()
        .putLong(DISPATCHER_CALLBACK_HANDLE_KEY, callbackHandle)
        .apply()
  }
}
