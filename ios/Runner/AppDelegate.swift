import CoinbaseWalletSDK
import Flutter
import GoogleMaps
import UIKit
import auto_connect

// Need this to register auto_connect headless runner
func registerPlugins(_ registry: FlutterPluginRegistry) {
    GeneratedPluginRegistrant.register(with: registry)
}

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GMSServices.provideAPIKey("AIzaSyD6mXR7XtiPugZ7a_ybwjIj7IsfGnLeUIA")
        GeneratedPluginRegistrant.register(with: self)
        SwiftAutoConnectPlugin.setPluginRegistrantCallback(registerPlugins(_:))
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // Coinbase Wallet SDK callback
    override func application(_ app: UIApplication,
                              open url: URL,
                              options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool
    {
        if (try? CoinbaseWalletSDK.shared.handleResponse(url)) == true {
            return true
        }
        return false
    }
    
    override func application(_ application: UIApplication,
                              continue userActivity: NSUserActivity,
                              restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        if let url = userActivity.webpageURL,
           (try? CoinbaseWalletSDK.shared.handleResponse(url)) == true {
            return true
        }
        return false
    }
}
