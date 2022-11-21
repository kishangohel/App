 import auto_connect
 import CoinbaseWalletSDK
import Flutter
import GoogleMaps
import UIKit

// Need this to register auto_connect headless runner
 func registerPlugins(_ registry: FlutterPluginRegistry) {
    GeneratedPluginRegistrant.register(with: registry)
 }

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication
            .LaunchOptionsKey: Any]?
    ) -> Bool {
        #if DEBUG
            let providerFactory = AppCheckDebugProviderFactory()
            AppCheck.setAppCheckProviderFactory(providerFactory)
        #endif
        GMSServices.provideAPIKey("AIzaSyDG-YS0daZzGspQdS7u00hATT3VCTFa2KM")
        UNUserNotificationCenter.current()
            .delegate = self as UNUserNotificationCenterDelegate
        GeneratedPluginRegistrant.register(with: self)
        SwiftAutoConnectPlugin.setPluginRegistrantCallback(registerPlugins(_:))
        return super.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
    }

    // Coinbase Wallet SDK callback
    override func application(
        _: UIApplication,
        open url: URL,
        options _: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        if url.scheme == "verifi-world" {
            if (try? CoinbaseWalletSDK.shared.handleResponse(url)) == true {
                return true
            }
        }
        return false
    }

    override func application(_: UIApplication,
                              continue userActivity: NSUserActivity,
                              restorationHandler _: @escaping (
                                  [UIUserActivityRestoring]?
                              )
                                  -> Void) -> Bool
    {
        if let url = userActivity.webpageURL,
           (try? CoinbaseWalletSDK.shared.handleResponse(url)) == true
        {
            return true
        }
        return false
    }
}
