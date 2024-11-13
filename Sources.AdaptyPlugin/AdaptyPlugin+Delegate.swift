//
//  File.swift
//  Adapty
//
//  Created by Aleksey Goncharov on 13.11.2024.
//

import AdaptyUI
import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptyPlugin {
    static var adaptyUICrossplatformDelegate: AdaptyPaywallControllerDelegate?

    public static func registerCrossplatformDelegate(_ delegate: AdaptyPaywallControllerDelegate) {
        adaptyUICrossplatformDelegate = delegate
    }
}
