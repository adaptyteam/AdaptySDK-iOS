//
//  Application.swift
//  Adapty
//
//  Created by Dmitry Obukhov on 3/17/20.
//

import Foundation

extension Adapty {
    enum Configuration {
        static let appleSearchAdsAttributionCollectionEnabled: Bool = {
            Bundle.main.infoDictionary?["AdaptyAppleSearchAdsAttributionCollectionEnabled"] as? Bool ?? false
        }()

        static var idfaCollectionDisabled: Bool = false

        static var observerMode: Bool = false
        static var sendSystemEventsEnabled: Bool = true
        static let storeKit2Enabled: Bool = false

        static var backendBaseUrl: URL?
        static var backendProxy: (host: String, port: Int)?
    }

    /// You can disable IDFA collecting by using this property. Make sure you call it before `.activate()` method.
    public static var idfaCollectionDisabled: Bool {
        get {
            Configuration.idfaCollectionDisabled
        }
        set {
            Adapty.logSystemEvent(AdaptySDKMethodRequestParameters(methodName: "idfa_collection_disabled", callId: Log.stamp, params: ["value": .value(newValue)]))
            Configuration.idfaCollectionDisabled = newValue
        }
    }

    public static func setBackendEnvironment(baseUrl: URL) {
        Configuration.backendBaseUrl = baseUrl
    }

    public static func setBackendEnvironment(withProxy host: String, withProxyPort port: Int) {
        Configuration.backendProxy = (host: host, port: port)
    }
}
