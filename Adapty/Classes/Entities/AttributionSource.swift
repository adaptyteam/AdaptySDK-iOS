//
//  AttributionSource.swift
//  Adapty
//
//  Created by Aleksei Valiano on 24.09.2022.
//

import Foundation

public enum AttributionSource: String, Equatable, Sendable {
    case adjust
    case appsflyer
    case branch
    case appleSearchAds = "apple_search_ads"
    case custom
}

extension AttributionSource: CustomStringConvertible {
    public var description: String { rawValue }
}
