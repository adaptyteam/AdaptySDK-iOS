//
//  AppDelegate.swift
//  AdaptyUIDemo
//
//  Created by Alexey Goncharov on 30.1.23..
//

import Adapty
import AdaptyUI
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Adapty.logLevel = .verbose
        Adapty.activate("YOUR_API_KEY")
        AdaptyUI.activate()

        return true
    }
}
