//
//  AppDelegate.swift
//  Adapty
//
//  Created by sugarofff@yandex.ru on 11/06/2019.
//  Copyright (c) 2019 sugarofff@yandex.ru. All rights reserved.
//

import Adapty
import Adjust
import AppsFlyerLib
import Branch
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if let _ = NSClassFromString("XCTest") {
            // If we're running tests, don't launch the main storyboard
            let viewController = UIViewController()
            let label = UILabel()
            label.text = "Running tests..."
            label.frame = viewController.view.frame
            label.textAlignment = .center
            label.textColor = .white
            viewController.view.addSubview(label)
            window?.rootViewController = viewController
            return true
        }

        Adapty.logLevel = .verbose
        Adapty.activate(AppConstants.adaptyApiKey, observerMode: false, customerUserId: nil)
        Adapty.delegate = PurchasesObserver.shared

        // in case you have / want to use fallback paywalls
        if let path = Bundle.main.path(forResource: "fallback_paywalls", ofType: "json"), let paywalls = try? String(contentsOfFile: path, encoding: .utf8) {
            Adapty.setFallbackPaywalls(paywalls) { _ in
                PurchasesObserver.shared.loadInitialPaywallData()
            }
        }

        // Configure Adjust
        
        let config = ADJConfig(appToken: AppConstants.adjustAppToken, environment: ADJEnvironmentProduction)
        config?.delegate = self
        Adjust.appDidLaunch(config)

        // Configure AppsFlyer
        AppsFlyerLib.shared().appsFlyerDevKey = AppConstants.appsFlyerDevKey
        AppsFlyerLib.shared().appleAppID = AppConstants.appleAppId
        AppsFlyerLib.shared().delegate = self
        AppsFlyerLib.shared().isDebug = true
        
        // Configure Branch
        Branch.getInstance().initSession(launchOptions: launchOptions) { (data, error) in
            if let data = data {
                Adapty.updateAttribution(data, source: .branch)
            }
        }
        
        // Configure Branch
        Branch.getInstance().setIdentity("YOUR_USER_ID")
        Branch.getInstance().initSession(launchOptions: launchOptions) { data, _ in
            if let data = data {
                Adapty.updateAttribution(data, source: .branch)
            }
        }

        return true
    }
}

extension AppDelegate: AdjustDelegate {
    func adjustAttributionChanged(_ attribution: ADJAttribution?) {
        // Just pass Adjust attribution to Adapty SDK
        if let attribution = attribution?.dictionary() {
            Adapty.updateAttribution(attribution, source: .adjust)
        }
    }
}

extension AppDelegate: AppsFlyerLibDelegate {
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable: Any]) {
        // It's important to include the network user ID
        Adapty.updateAttribution(conversionInfo, source: .appsflyer, networkUserId: AppsFlyerLib.shared().getAppsFlyerUID())
    }

    func onConversionDataFail(_ error: Error) {
        // handle error
    }
}
