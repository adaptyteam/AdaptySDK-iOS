//
//  AdaptyPaywall+ViewConfiguration.swift.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 10.04.2024
//
//

import Foundation

extension AdaptyPaywall {
    enum ViewConfiguration {
        case noData
        case data(AdaptyUI.ViewConfiguration)

        var adaptyLocale: AdaptyLocale? {
            switch self {
            case .noData: nil
            case let .data(data): data.responseLocale
            }
        }
    }
}
