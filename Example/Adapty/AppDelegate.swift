//
//  AppDelegate.swift
//  Adapty
//
//  Created by sugarofff@yandex.ru on 11/06/2019.
//  Copyright (c) 2019 sugarofff@yandex.ru. All rights reserved.
//

import UIKit
import Adapty
import Adjust
import AppsFlyerLib
import Branch

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Adapty.logLevel = .verbose
        Adapty.activate("YOUR_ADAPTY_APP_TOKEN")
        Adapty.delegate = self
        
        // Configure Adjust
        
        // Configure AppsFlyer
        
        // Configure Branch
        
        Branch.getInstance().setIdentity("YOUR_USER_ID")
        Branch.getInstance().initSession(launchOptions: launchOptions) { (data, error) in
            if let data = data {
                Adapty.updateAttribution(data, source: .branch)
            }
        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        Adapty.handlePushNotification(userInfo) { (_) in
            completionHandler(UIBackgroundFetchResult.newData)
        }
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

extension AppDelegate: AppsFlyerTrackerDelegate {
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        // It's important to include the network user ID
        Adapty.updateAttribution(conversionInfo, source: .appsflyer, networkUserId: AppsFlyerTracker.shared().getAppsFlyerUID())
    }

    func onConversionDataFail(_ error: Error) {
        
    }
}

extension AppDelegate: AdaptyDelegate {
    
    func didReceiveUpdatedPurchaserInfo(_ purchaserInfo: PurchaserInfoModel) {
        // handle any changes to purchaserInfo
    }
    
    func didReceivePromo(_ promo: PromoModel) {
        // handle available promo
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PromoUpdated"), object: promo)
    }
    
}
