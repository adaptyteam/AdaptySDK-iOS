//
//  AppDelegate.swift
//  Adapty
//
//  Created by sugarofff@yandex.ru on 11/06/2019.
//  Copyright (c) 2019 sugarofff@yandex.ru. All rights reserved.
//

import Adapty
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    private func instantiateTestingController() -> UIViewController {
        UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TestingController")
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if NSClassFromString("XCTest") != nil {
            window?.rootViewController = instantiateTestingController()
            return true
        }

        Adapty.delegate = PurchasesObserver.shared
        Adapty.logLevel = .debug
        Adapty.setLogHandler { date, level, message in
            LogsObserver.shared.postMessage(date, level, message)
            NSLog("%@", message)
        }

        Adapty.activate(AppConstants.adaptyApiKey,
                        useStoreKit2: .enableToDetermineIntroductoryOfferEligibility) { _ in
            PurchasesObserver.shared.loadInitialProfileData()
            PurchasesObserver.shared.loadInitialPaywallData()
        }

        // in case you have / want to use fallback paywalls
        if let urlPath = Bundle.main.url(forResource: "fallback_paywalls", withExtension: "json"),
           let paywallsData = try? Data(contentsOf: urlPath) {
            Adapty.setFallbackPaywalls(paywallsData) { _ in
                // handle error
            }
        }

        return true
    }
}
