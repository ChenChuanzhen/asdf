//
//  AppDelegate.swift
//  asdf
//
//  Created by admin on 2026/2/5.
//

import UIKit

// MARK: - Notification Name Extensions
extension Notification.Name {
    static let tokenExpired = Notification.Name("tokenExpired")
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupTokenExpiredObserver()
        return true
    }
    
    private func setupTokenExpiredObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleTokenExpired),
                                               name: .tokenExpired,
                                               object: nil)
    }
    
    @objc private func handleTokenExpired() {
        DispatchQueue.main.async {
            AppRouter.shared.navigateToLogin()
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

