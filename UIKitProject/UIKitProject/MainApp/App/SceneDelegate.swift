//
//  SceneDelegate.swift
//  UIKitProject
//
//  Created by Rath! on 12/8/24.
//

import UIKit

let statusBarFrame = 0
let navigationBarFrame = 0

//✅ SwiftUI inside UIKit (UIHostingController)
//✅ UIKit inside SwiftUI (UIViewRepresentable)

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    internal var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        printFontsName()
        networkMonitoring()
        rootViewController(scene: scene)
        AppManager.setCustomNavigationBarAppearance()
    }
}



extension SceneDelegate {
    
    static var sharedInstance: SceneDelegate? {
        return UIApplication.shared.connectedScenes
            .first { $0.activationState == .foregroundActive }?
            .delegate as? SceneDelegate
    }
    
    private func printFontsName(){
        
        for family in UIFont.familyNames {
            print("Font Family: \(family)")
            for fontName in UIFont.fontNames(forFamilyName: family) {
                print("    \(fontName)")
            }
        }
        
        print("✅ Already print font in App.")
    }
    
    private func networkMonitoring(){
        NetworkMonitorManager.shared.onStatusChange = { isConnected in
            
            if isConnected {
                print("✅ Internet connected")
                
            } else {
                print("❌ Internet disconnected")
            }
        }
    }

    private func rootViewController(scene: UIScene){
        
//        let loginSuccessfully = UserDefaults.standard.bool(forKey: AppConstants.loginSuuccess)
        let controller: UIViewController = SplashScreenVC()
        
        let navigation = UINavigationController(rootViewController: controller)
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window!.rootViewController = navigation
        window!.makeKeyAndVisible()
        window!.overrideUserInterfaceStyle = .light
        
        print("✅ Root ViewController.")
    }
    
    func changeRootViewController(to controller: UIViewController) {
        
        guard let window = self.window else { return }
        
        // Optional: wrap in navigation controller if needed
        let nav = UINavigationController(rootViewController: controller)
        
        // add animation
        UIView.transition(with: window,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: {
            window.rootViewController = nav
        })
        
        print("✅ Change Root ViewController.")
    }
}

// MARK: - App lifecycle
extension SceneDelegate {
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        print("sceneWillEnterForeground") // App is coming to the foreground but not yet active. (From background)
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        print("sceneDidBecomeActive") // App is now active and interactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        print("sceneWillResignActive") // App is about to move from active to inactive (e.g., user pressed Home button).
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        print("sceneDidEnterBackground") // App is now in the background but not terminated.
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        print("sceneDidDisconnect") // Scene is removed (e.g., app is fully closed or scene is discarded).
    }
}

// MARK: - Global variable
var windowSceneDelegate: UIWindow!
var barAppearanHeight: CGFloat = 90
var bottomSafeAreaInsetsHeight: CGFloat!
let screen = UIScreen.main.bounds
let igorneSafeAeaTop: CGRect = CGRect(x: 0,
                                      y: Int(barAppearanHeight),
                                      width: Int(screen.width),
                                      height: Int(screen.height-barAppearanHeight))
