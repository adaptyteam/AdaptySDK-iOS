//
//  AppDelegate+ThirdPartyLibs.swift
//  Adapty_Example
//
//  Created by Aleksey Goncharov on 02.11.2022.
//  Copyright © 2022 Adapty. All rights reserved.
//

import Adapty
import Adjust
import AppsFlyerLib
import Branch
import Foundation

extension AppDelegate {
    func configureThirdPartyAnalytics(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        configureAdjust(launchOptions)
        configureAppsflyer(launchOptions)
        configureBranch(launchOptions)
    }

    private func configureAdjust(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        let config = ADJConfig(appToken: AppConstants.adjustAppToken, environment: ADJEnvironmentProduction)
        config?.delegate = self
        Adjust.appDidLaunch(config)
    }

    private func configureAppsflyer(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        AppsFlyerLib.shared().appsFlyerDevKey = AppConstants.appsFlyerDevKey
        AppsFlyerLib.shared().appleAppID = AppConstants.appleAppId
        AppsFlyerLib.shared().delegate = self
        AppsFlyerLib.shared().isDebug = true
        AppsFlyerLib.shared().start()
    }

    private func configureBranch(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        Branch.setUseTestBranchKey(true)
        Branch.getInstance().initSession(launchOptions: launchOptions) { data, _ in
            if let data = data {
                Adapty.updateAttribution(data, source: .branch)
            }
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

extension AppDelegate: AppsFlyerLibDelegate {
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable: Any]) {
        // It's important to include the network user ID
        Adapty.updateAttribution(conversionInfo, source: .appsflyer, networkUserId: AppsFlyerLib.shared().getAppsFlyerUID())
    }

    func onConversionDataFail(_ error: Error) {
        // handle error
    }
}
