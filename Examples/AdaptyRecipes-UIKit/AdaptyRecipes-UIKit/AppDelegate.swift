//
//  AppDelegate.swift
//  AdaptyRecipes-UIKit
//
//  Created by Aleksey Goncharov on 01.07.2024.
//

import Adapty
import AdaptyUI
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    private let viewModel = MainViewModel()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let adaptyConfigBuilder = Adapty.Configuration
            .Builder(withAPIKey: AppConstants.adaptyApiKey)
            .with(customerUserId: UserManager.currentUserId)

        Adapty.delegate = viewModel
        Adapty.logLevel = .verbose
        Adapty.activate(with: adaptyConfigBuilder)

        if #available(iOS 15.0, *) {
            AdaptyUI.activate()
        }

        return true
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
