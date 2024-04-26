//
//  AppDelegate.swift
//  Adapty-Demo
//
//  Created by Elena Gordienko on 01.08.22.
//  Copyright © 2022 Adapty. All rights reserved.
//

import Adapty
import Foundation
import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {

    // MARK: - Configuration of Adapty SDK

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        Adapty.logLevel = .verbose
        Adapty.activate("YOUR_ADAPTY_APP_TOKEN", customerUserId: nil)
        return true
    }
}
