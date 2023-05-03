

import UIKit
import Flutter
import CoreLocation
import Network
import NetworkExtension
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, CLLocationManagerDelegate {
    private var methodChannel: FlutterMethodChannel?
    private var locationManager: CLLocationManager?
    private var pathMonitor: Network.NWPathMonitor?
    private var currentPath: Network.NWPath?
    
    private var backgroundMethodChannel: FlutterMethodChannel?
    private var backgroundFlutterEngine: FlutterEngine?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        methodChannel = FlutterMethodChannel(name: "world.verifi.app", binaryMessenger: controller.binaryMessenger)
        methodChannel?.setMethodCallHandler(handleMethodCall)

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func handleMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startNetworkMonitor":
            startService()
            result(nil)
        case "stopNetworkMonitor":
            stopService()
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func startService() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.pausesLocationUpdatesAutomatically = false
        locationManager?.startMonitoringSignificantLocationChanges()
        
        pathMonitor = NWPathMonitor(requiredInterfaceType: .wifi)
        currentPath = pathMonitor?.currentPath
        print("Initial path: \(String(describing: currentPath?.status))")
        let queue = DispatchQueue(label: "NetworkMonitor")
        pathMonitor?.start(queue: queue)
        pathMonitor?.pathUpdateHandler = { [weak self] path in
            if path.status == .satisfied && path.usesInterfaceType(.wifi) {
                DispatchQueue.main.async {
                    self?.handleNetworkChange()
                }
            }
        }
    }
    
    private func stopService() {
        locationManager?.stopMonitoringSignificantLocationChanges()
        locationManager?.delegate = nil
        locationManager = nil
        
        pathMonitor?.cancel()
        pathMonitor = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.getWiFiSSID { [weak self] bssid, ssid in
            self?.sendToFirebase(bssid, ssid, location)
        }
    }
    
    private func handleNetworkChange() {
        DispatchQueue.global().async {
            guard let locationManager = self.locationManager,
                  let location = locationManager.location else { return }
            self.getWiFiSSID { [weak self] bssid, ssid in
                self?.sendToFirebase(bssid, ssid, location)
            }
        }
    }
        
    private func getWiFiSSID(completion: @escaping (String, String) -> Void) {
        NEHotspotNetwork.fetchCurrent { network in
            if let bssid = network?.bssid,
            let ssid = network?.ssid {
                completion(bssid, ssid)
            }
        }
    }
    
    private func sendToFirebase(_ bssid: String, _ ssid: String, _ location: CLLocation) {
        let functions = Functions.functions()
        let data: [String: Any] = [
            "bssid": bssid,
            "ssid": ssid,
            "lat": location.coordinate.latitude,
            "lng": location.coordinate.longitude,
        ]
        functions.httpsCallable("newNetwork").call(data) { (result, error) in
                    if let error = error as NSError? {
                        print("Error sending data to Firebase Cloud Function: \(error.localizedDescription)")
                        return
                    }
                    if let response = (result?.data as? [String: Any]) {
                        print("Response from Firebase Cloud Function: \(response)")
                    }
                }
    }
}

