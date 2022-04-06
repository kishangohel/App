package world.verifi.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.os.Build
import android.util.Log
import androidx.core.content.ContextCompat.getSystemService
import androidx.work.*
import com.google.android.gms.location.GeofenceStatusCodes
import com.google.android.gms.location.GeofencingEvent


class GeofenceBroadcastReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "GeoBroadcastReceiver"
    }

    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "Received new geofence event")

        val callbackHandle = intent.getLongExtra(MainActivity.CALLBACK_HANDLE_KEY, 0)
        val geofencingEvent = GeofencingEvent.fromIntent(intent)
        if (geofencingEvent.hasError()) {
            val errorMessage = GeofenceStatusCodes.getStatusCodeString(geofencingEvent.errorCode)
            Log.e(TAG, errorMessage)
            return
        }
        val workManager = WorkManager.getInstance(context)
        val location = geofencingEvent.triggeringLocation
        val data = Data.Builder()
            .putLong(GeofenceWorker.CALLBACK_HANDLE, callbackHandle)
            .putStringArray(
                GeofenceWorker.FENCE_IDS,
                geofencingEvent.triggeringGeofences.map { it.requestId }.toTypedArray()
            )
            .putDouble(GeofenceWorker.LAT, location.latitude)
            .putDouble(GeofenceWorker.LNG, location.longitude).build()
        val request = OneTimeWorkRequestBuilder<GeofenceWorker>()
            .setInputData(data)
            .setExpedited(OutOfQuotaPolicy.RUN_AS_NON_EXPEDITED_WORK_REQUEST).build()
        workManager.enqueue(request)
        Log.d(TAG, "Geofence work enqueued")
    }
}
