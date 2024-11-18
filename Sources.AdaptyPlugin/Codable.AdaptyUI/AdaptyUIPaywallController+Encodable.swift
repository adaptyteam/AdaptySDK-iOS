//
//  AdaptyUIPaywallController+Encodable.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 14.11.2024.
//

#if canImport(UIKit)

import AdaptyUI
import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
public extension AdaptyPaywallController {
    var asAdaptyJsonData: AdaptyJsonData {
        get throws {
            try toView().asAdaptyJsonData
        }
    }
}

#endif
