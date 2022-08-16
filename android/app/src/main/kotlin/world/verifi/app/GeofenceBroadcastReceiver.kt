package world.verifi.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.work.Data
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.OutOfQuotaPolicy
import androidx.work.WorkManager
import com.google.android.gms.location.GeofenceStatusCodes
import com.google.android.gms.location.GeofencingEvent


class GeofenceBroadcastReceiver : BroadcastReceiver() {
  companion object {
    private const val TAG = "GeoBroadcastReceiver"
  }

  override fun onReceive(context: Context, intent: Intent) {
    Log.d(TAG, "Received new geofence event")

    val callbackHandle =
      intent.getLongExtra(MainActivity.CALLBACK_HANDLE_KEY, 0)
    val geofencingEvent = GeofencingEvent.fromIntent(intent) ?: return
    if (geofencingEvent.hasError()) {
      val errorMessage =
        GeofenceStatusCodes.getStatusCodeString(geofencingEvent.errorCode)
      Log.e(TAG, errorMessage)
      return
    }
    val workManager = WorkManager.getInstance(context)
    val location = geofencingEvent.triggeringLocation ?: return
    val geofences = geofencingEvent.triggeringGeofences ?: return
    val data = Data.Builder()
      .putLong(BackgroundWorker.CALLBACK_HANDLE, callbackHandle)
      .putDouble(BackgroundWorker.GF_LAT, location.latitude)
      .putDouble(BackgroundWorker.GF_LNG, location.longitude)
      .build()
    val request = OneTimeWorkRequestBuilder<BackgroundWorker>()
      .setInputData(data)
      .setExpedited(OutOfQuotaPolicy.RUN_AS_NON_EXPEDITED_WORK_REQUEST).build()
    workManager.enqueue(request)
    Log.d(TAG, "Geofence work enqueued")
  }
}
