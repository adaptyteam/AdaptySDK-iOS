//
//  AttributionNetwork.swift
//  Adapty
//
//  Created by Alexey Valiano on 11.08.2022.
//

import Foundation

@objc public enum AttributionNetwork: UInt {
    case adjust
    case appsflyer
    case branch
    case appleSearchAds
    case custom

    var rawSource: String {
        switch self {
        case .adjust:
            return "adjust"
        case .appsflyer:
            return "appsflyer"
        case .branch:
            return "branch"
        case .appleSearchAds:
            return "apple_search_ads"
        case .custom:
            return "custom"
        }
    }
}
