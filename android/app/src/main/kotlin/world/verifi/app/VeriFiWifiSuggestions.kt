package world.verifi.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.wifi.WifiManager
import android.net.wifi.WifiNetworkSuggestion
import android.os.Build
import androidx.annotation.RequiresApi

class VeriFiWifiSuggestions {

    companion object {
        @RequiresApi(Build.VERSION_CODES.Q)
        fun transformWifisToSuggestions(wifis: List<List<String>>): List<WifiNetworkSuggestion> {
            val suggestions = mutableListOf<WifiNetworkSuggestion>()
            for (wifi in wifis) {
                val suggestion = createWifiSuggestion(wifi[0], wifi[1])
                suggestions.add(suggestion)
            }
            return suggestions.toList()
        }

        @RequiresApi(Build.VERSION_CODES.Q)
        fun createWifiSuggestion(ssid: String, password: String?): WifiNetworkSuggestion {
            return WifiNetworkSuggestion.Builder().apply {
                this.setSsid(ssid)
                if (password != null) {
                    this.setWpa2Passphrase(password)
                }
            }.build()
        }
    }
}
