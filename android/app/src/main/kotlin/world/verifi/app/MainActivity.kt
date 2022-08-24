package world.verifi.app

import android.Manifest
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.util.Log
import androidx.core.app.ActivityCompat
import com.google.android.gms.location.*
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity(), MethodChannel.MethodCallHandler {
  private val channelName = "world.verifi.app/channel"
  private lateinit var geofencingClient: GeofencingClient
  private lateinit var activityRecognitionClient: ActivityRecognitionClient

  companion object {
    private const val TAG = "MainActivity"
    const val SHARED_PREFERENCES_KEY = "world.verifi.app.shared_preferences_key"
    const val DISPATCHER_CALLBACK_HANDLE_KEY = "dispatcherCallbackHandle"
    const val CALLBACK_HANDLE_KEY = "callbackHandleKey"

    /**
     * Registers a list of geofences
     */
    @JvmStatic
    fun registerGeofences(
      ctx: Context,
      gfClient: GeofencingClient,
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
              Geofence.GEOFENCE_TRANSITION_DWELL
                  or Geofence.GEOFENCE_TRANSITION_ENTER
            )
            // 20 seconds
            .setLoiteringDelay(20000)
            .setExpirationDuration(Geofence.NEVER_EXPIRE)
            .build()
        geofences.add(geofence)
      }
      // First check to make sure we have required permissions
      if (ActivityCompat.checkSelfPermission(
          ctx,
          Manifest.permission.ACCESS_FINE_LOCATION,
        ) != PackageManager.PERMISSION_GRANTED
      ) {
        Log.d(
          TAG,
          "Unable to register geofence due to lack of permissions.",
        )
        return
      }
      // Add the geofences
      gfClient.addGeofences(
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
      return GeofencingRequest.Builder().apply { addGeofences(geofences) }
        .build()
    }

    @JvmStatic
    private fun getGeofencePendingIndent(
      context: Context,
      callbackHandle: Long,
    ): PendingIntent {
      val intent =
        Intent(context, GeofenceBroadcastReceiver::class.java)
          .putExtra(CALLBACK_HANDLE_KEY, callbackHandle)
      return PendingIntent.getBroadcast(
        context,
        0,
        intent,
        PendingIntent.FLAG_UPDATE_CURRENT
      )
    }

    @JvmStatic
    private fun requestActivityRecognitionUpdates(
      ctx: Context,
      arClient: ActivityRecognitionClient,
      args: ArrayList<*>,
      result: MethodChannel.Result?
    ) {
      val callbackHandle = args[0] as Long
      val request = buildActivityRecognitionRequest()
      val pendingIntent =
        getActivityRecognitionPendingIntent(ctx, callbackHandle)
      if (ActivityCompat.checkSelfPermission(
          ctx,
          Manifest.permission.ACTIVITY_RECOGNITION,
        ) != PackageManager.PERMISSION_GRANTED
      ) {
        Log.d(
          TAG,
          "Unable to register activity transition receiver due to lack of permission",
        )
        return
      }
      arClient.requestActivityTransitionUpdates(request, pendingIntent).run {
        addOnSuccessListener {
          Log.d(TAG, "Activity recognition initialized successfully")
          result?.success(true)
        }

        addOnFailureListener {
          Log.e(TAG, "Failed to initialize activity recognition")
          result?.error(it.toString(), it.message, it.localizedMessage)
        }
      }

    }

    @JvmStatic
    private fun buildActivityRecognitionRequest(): ActivityTransitionRequest {
      val transitions = mutableListOf<ActivityTransition>()
      transitions.add(
        ActivityTransition.Builder()
          .setActivityType(DetectedActivity.STILL)
          .setActivityTransition(ActivityTransition.ACTIVITY_TRANSITION_ENTER)
          .build()
      )
      return ActivityTransitionRequest(transitions)
    }

    @JvmStatic
    private fun getActivityRecognitionPendingIntent(
      context: Context,
      callbackHandle: Long
    ): PendingIntent {
      val intent = Intent(
        context,
        ActivityRecognitionBroadcastReceiver::class.java
      ).putExtra(
        CALLBACK_HANDLE_KEY, callbackHandle
      )
      return PendingIntent.getBroadcast(
        context,
        0,
        intent,
        PendingIntent.FLAG_UPDATE_CURRENT
      )
    }
  }


  /**
   * Initialize geofencing client and activity recognition client
   */

  /**
   * Initialize geofencing client, activity recognition client, and method channel
   */
  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    geofencingClient = LocationServices.getGeofencingClient(this)
    activityRecognitionClient = ActivityRecognition.getClient(this)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
      .setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    val args = call.arguments() as ArrayList<*>?
    when (call.method) {
      "initialize" -> {
        if (args.isNullOrEmpty()) {
          result.error(
            "no-args",
            "Invalid arguments to initialize",
            null,
          )
          return
        }
        val dispatcherHandle = args[0] as Long
        initializeCallbackHandle(this, dispatcherHandle)
        Notifications.createNotificationChannel(this)
        result.success(true)
      }
      "registerGeofences" -> {
        if (args.isNullOrEmpty()) {
          result.error(
            "no-args",
            "Invalid arguments to registerGeofence",
            null,
          )
          return
        }
        registerGeofences(this, geofencingClient, args, result)
      }
      "startActivityRecognition" -> {
        if (args.isNullOrEmpty()) {
          result.error(
            "no-args",
            "Invalid arguments to startActivityRecognition",
            null,
          )
          return
        }
        requestActivityRecognitionUpdates(
          this,
          activityRecognitionClient,
          args,
          result
        )
      }
      else -> result.notImplemented()
    }
  }

  /**
   * Store callback handle in shared preferences
   */
  private fun initializeCallbackHandle(ctx: Context, callbackHandle: Long) {
    Log.d(TAG, "Saving callback handle")
    ctx.getSharedPreferences(SHARED_PREFERENCES_KEY, Context.MODE_PRIVATE)
      .edit()
      .putLong(DISPATCHER_CALLBACK_HANDLE_KEY, callbackHandle)
      .apply()
  }
}
