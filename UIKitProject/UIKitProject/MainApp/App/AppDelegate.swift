//
//  AppDelegate.swift
//  UIKitProject
//
//  Created by Rath! on 12/8/24.
//

import UIKit
import WebKit
//import GoogleMaps
//import FirebaseCore
//import FirebaseMessaging
//import FirebaseCrashlytics
//import LocalAuthentication


import Firebase
import FirebaseMessaging
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private var orientationLock = UIInterfaceOrientationMask.portrait
    private let gcmMessageIDKey = "gcm.message_id"
    
    
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        print("✅ didFinishLaunchingWithOptions.")
        
       
        //        configureGoogleMaps()
        warmUpWebView()
        printAppConfiguration()
        configureNotification(application)
        return true
    }
    
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Handle discarded scenes if needed
    }
}


// MARK: - Google Maps Configuration
//private extension AppDelegate {
//    func configureGoogleMaps() {
//        print("==> apiKey: \(AppConfiguration.shared.apiKey)")
//        GMSServices.provideAPIKey(AppConfiguration.shared.apiKey)
//    }
//}

// MARK: - Live location
//extension AppDelegate{
//
//    private func handleNearbyLocation(){
//
//        LocationManager.shared.getCurrentLocation(isLiveLocation: true) { [self] currentLocation in
//
//            guard let location = currentLocation else { return }
//
//            // Fixed coordinate (Phnom Penh)
//            let toLocation = CLLocation(latitude: 11.5564, longitude: 104.9282)
//
//            let km =  LocationManager.shared.distance(from: location, to: toLocation, unit: .meters)
//
//            if km < 500{
//                LocationManager.shared.stopUpdatingLocation()
//                pushNotificationNearby()
//            }
//        }
//    }
//
//    func pushNotificationNearby(title: String = "Message", body: String = "Nearby location"){
//        let content = UNMutableNotificationContent()
//        content.title = title
//        content.body = body
//        content.sound = UNNotificationSound.default
//
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false) // 60 seconds for testing
//
//        let request = UNNotificationRequest(identifier: "scheduledNotification", content: content, trigger: trigger)
//
//        UNUserNotificationCenter.current().add(request) { error in
//            if let error = error {
//                print("Error scheduling notification: \(error.localizedDescription)")
//            } else {
//                print("Notification scheduled successfully.")
//            }
//        }
//    }
//}

// MARK: - App Orientation
//extension AppDelegate{
//
//    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
//        return orientationLock
//    }
//
//    struct AppLockOrientationManager {
//
//        static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
//            if let delegate = UIApplication.shared.delegate as? AppDelegate {
//                delegate.orientationLock = orientation
//            }
//        }
//
//        // Forces the device to rotate to the specified orientation
//        static func lockOrientation(_ orientation: UIInterfaceOrientationMask,
//                                    andRotateTo rotateOrientation:UIInterfaceOrientation) {
//            self.lockOrientation(orientation)
//            UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
//        }
//
//        // AppLockOrientationManager.lockOrientation(.portrait)
//        // AppLockOrientationManager.lockOrientation(.landscape, andRotateTo: .landscapeRight)
//    }
//}

// MARK: - App lifecycle methods
extension AppDelegate{
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("App did become active")
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        print("App will resign active")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("App entered background")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("App will enter foreground")
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("App will terminate") // kill app
    }
    
}



extension AppDelegate{
    
    /// Minimal warm-up WebView to reduce first-load lag
    private func warmUpWebView() {
        let _ = WKWebView(frame: .zero)
    }
}


//MARK: - Handle notification
extension AppDelegate{
    
    func configureNotification(_ application: UIApplication){
        // Initialize Firebase (only once)
        FirebaseApp.configure()
        
        // Set delegates
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        
        // Ask permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ Notification permission granted.")
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            } else {
                print("❌ Notification permission denied.")
            }
        }
    }
    
    
    // Called when APNs has successfully registered your app
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("📱 Device Token: \(token)")
    }
    
    // Called when registration failed
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❌ Failed to register: \(error.localizedDescription)")
    }
    
}


extension AppDelegate: MessagingDelegate{
    // Called when Firebase issues a new registration token (FCM token)
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else { return }
        print("🔥 Firebase FCM Token: \(fcmToken)")
        // Optionally: send this token to your backend server
    }
}


extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound, .badge])
        } else {
            completionHandler([.sound, .badge])
        }
    }
    
    
    // Handle when user taps notification
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("📩 User tapped notification with data: \(userInfo)")
        completionHandler()
    }
}






