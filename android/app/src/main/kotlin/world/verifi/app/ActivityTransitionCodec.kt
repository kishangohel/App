package world.verifi.app

import com.google.android.gms.location.DetectedActivity

object ActivityRecognitionCodec {
    private fun getActivityString(detectedActivityType: Int): String {
        return when (detectedActivityType) {
            DetectedActivity.IN_VEHICLE -> "IN_VEHICLE"
            DetectedActivity.ON_BICYCLE -> "ON_BICYCLE"
            DetectedActivity.ON_FOOT -> "ON_FOOT"
            DetectedActivity.RUNNING -> "RUNNING"
            DetectedActivity.STILL -> "STILL"
            DetectedActivity.TILTING -> "TILTING"
            DetectedActivity.UNKNOWN -> "UNKNOWN"
            DetectedActivity.WALKING -> "WALKING"
            else -> "UNDEFINED"
        }
    }

    fun encodeResult(activity: Int): String {
        val builder = StringBuilder()
        builder.append("{")
        builder.append("\"type\":\"" + getActivityString(activity) + "\"")
        builder.append("}")
        return builder.toString()
    }
}
