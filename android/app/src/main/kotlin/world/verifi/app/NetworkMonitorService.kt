package world.verifi.app

import android.Manifest
import android.app.*
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.location.Location
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.net.wifi.WifiInfo
import android.net.wifi.WifiManager
import android.os.IBinder
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.Priority
import com.google.android.gms.tasks.CancellationTokenSource
import com.google.firebase.functions.FirebaseFunctionsException
import com.google.firebase.functions.ktx.functions
import com.google.firebase.ktx.Firebase

class NetworkMonitorService : Service() {
    private lateinit var fusedLocationClient: FusedLocationProviderClient
    private lateinit var wifiManager: WifiManager
    private lateinit var connectivityManager: ConnectivityManager
    private lateinit var cancellationTokenSource: CancellationTokenSource

    private var lastWifiInfo: WifiInfo? = null

    private val networkCallback = object : ConnectivityManager.NetworkCallback(
        FLAG_INCLUDE_LOCATION_INFO
    ) {
        override fun onCapabilitiesChanged(
            network: Network,
            networkCapabilities: NetworkCapabilities
        ) {
            super.onCapabilitiesChanged(network, networkCapabilities)
            val hasInternet =
                networkCapabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
            val isWifi = networkCapabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)
            if (isWifi && hasInternet) {
                val transportInfo = networkCapabilities.transportInfo.takeIf { it is WifiInfo }
                    ?.let { it as WifiInfo }
                // only send network info if the ssid has changed
                if (transportInfo != null && (lastWifiInfo == null || lastWifiInfo?.ssid != transportInfo.ssid)) {
                    lastWifiInfo = transportInfo
                    getCurrentLocation(transportInfo) { wifiInfo, location ->
                        sendNetworkInfo(wifiInfo, location)
                    }
                }
            }
        }
    }

    companion object {
        private const val TAG = "NetworkMonitorService"
        private const val NOTIFICATION_ID = 1

        fun startService(context: Context) {
            val intent = Intent(context, NetworkMonitorService::class.java)
            context.startForegroundService(intent)
        }

        fun stopService(context: Context) {
            val intent = Intent(context, NetworkMonitorService::class.java)
            context.stopService(intent)
        }
    }

    override fun onCreate() {
        super.onCreate()
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)
        wifiManager = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
        connectivityManager =
            applicationContext.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        cancellationTokenSource = CancellationTokenSource()

        val channelId = createNotificationChannel()
        val notification = buildNotification(channelId)
        startForeground(NOTIFICATION_ID, notification)

        val networkRequest = NetworkRequest.Builder()
            .addTransportType(NetworkCapabilities.TRANSPORT_WIFI)
            .build()
        connectivityManager.registerNetworkCallback(networkRequest, networkCallback)
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onDestroy() {
        super.onDestroy()
        val cm = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        cm.unregisterNetworkCallback(networkCallback)
        cancellationTokenSource.cancel()
    }

    private fun createNotificationChannel(): String {
        val channelId = "auto_connect_channel"
        val channelName = "Auto Connect Service"

        val channel =
            NotificationChannel(channelId, channelName, NotificationManager.IMPORTANCE_LOW)
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.createNotificationChannel(channel)
        return channelId
    }

    private fun buildNotification(channelId: String): Notification {
        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, notificationIntent, PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, channelId)
            .setContentTitle("VeriFi is running")
            .setContentText("Receiving real-time nearby contribution and validation opportunities")
            .setSmallIcon(R.drawable.app_icon) // Replace with your own notification icon
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .build()
    }

    private fun getCurrentLocation(
        wifiInfo: WifiInfo,
        callback: (wifiInfo: WifiInfo, location: Location) -> Unit
    ) {
        if (ActivityCompat.checkSelfPermission(
                this,
                Manifest.permission.ACCESS_FINE_LOCATION
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            return
        }

        fusedLocationClient.getCurrentLocation(Priority.PRIORITY_HIGH_ACCURACY, null)
            .addOnSuccessListener { location ->
                callback(wifiInfo, location)
            }
    }

    private fun sendNetworkInfo(wifiInfo: WifiInfo, location: Location) {
        // Create the arguments to the callable function.
        val data = hashMapOf(
            "bssid" to wifiInfo.bssid,
            "ssid" to wifiInfo.ssid,
            "lat" to location.latitude,
            "lng" to location.longitude,
        )
        Firebase.functions.getHttpsCallable("newNetwork").call(data)
            .addOnSuccessListener { result ->
                Log.d(TAG, "Successfully sent network info: $result")
            }
            .addOnFailureListener { exception ->
                if (exception is FirebaseFunctionsException) {
                    Log.e(TAG, "Error code: ${exception.code}")
                    Log.e(TAG, "Error message: ${exception.message}")
                    Log.e(TAG, "Error details: ${exception.details}")
                } else {
                    Log.e(TAG, "Error calling Cloud Function", exception)
                }
            }
    }

}