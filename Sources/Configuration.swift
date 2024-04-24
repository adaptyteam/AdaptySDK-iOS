//
//  Configuration.swift
//  AdaptySDK
//
//  Created by Dmitry Obukhov on 3/17/20.
//

import Foundation

extension Adapty {
    public struct Configuration {
        let apiKey: String
        let customerUserId: String?
        let observerMode: Bool
        let idfaCollectionDisabled: Bool
        let ipAddressCollectionDisabled: Bool
        let dispatchQueue: DispatchQueue
        let backendBaseUrl: URL
        let backendFallbackBaseUrl: URL
        let backendProxy: (host: String, port: Int)?
    }
}

extension Adapty.Configuration {
    static let appleSearchAdsAttributionCollectionEnabled: Bool = Bundle.main.infoDictionary?["AdaptyAppleSearchAdsAttributionCollectionEnabled"] as? Bool ?? false

    static var idfaCollectionDisabled: Bool = false
    static var ipAddressCollectionDisabled: Bool = false
    static var observerMode: Bool = false

    static var storeKit2Enabled: String {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) else { return "unavailable" }
        return "enabled"
    }
}

extension Backend {
    init(with configuration: Adapty.Configuration) {
        self.init(
            secretKey: configuration.apiKey,
            baseURL: configuration.backendBaseUrl,
            withProxy: configuration.backendProxy
        )
    }
}

extension FallbackBackend {
    init(with configuration: Adapty.Configuration) {
        self.init(
            secretKey: configuration.apiKey,
            baseURL: configuration.backendFallbackBaseUrl,
            withProxy: configuration.backendProxy
        )
    }
}
