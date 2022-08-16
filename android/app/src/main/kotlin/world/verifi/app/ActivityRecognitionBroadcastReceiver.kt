package world.verifi.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.work.Data
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.OutOfQuotaPolicy
import androidx.work.WorkManager
import com.google.android.gms.location.ActivityTransitionResult


class ActivityRecognitionBroadcastReceiver : BroadcastReceiver() {
  companion object {
    private const val TAG = "ActivityRecognitionBroadcastReceiver"
  }

  override fun onReceive(context: Context, intent: Intent) {
    Log.d(TAG, "Received new activity transition event")
    if (ActivityTransitionResult.hasResult(intent)) {
      val result = ActivityTransitionResult.extractResult(intent) ?: return
      val workManager = WorkManager.getInstance(context)
      val callbackHandle =
        intent.getLongExtra(MainActivity.CALLBACK_HANDLE_KEY, 0)
      val data =
        Data.Builder()
          .putLong(BackgroundWorker.CALLBACK_HANDLE, callbackHandle)
          .build()
      val request =
        OneTimeWorkRequestBuilder<BackgroundWorker>().setInputData(data)
          .setExpedited(OutOfQuotaPolicy.RUN_AS_NON_EXPEDITED_WORK_REQUEST)
          .build()
      workManager.enqueue(request)
      Log.d(TAG, "Activity recognition work enqueued")
    }
  }
}
