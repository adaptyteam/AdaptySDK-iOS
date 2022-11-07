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
    }

    /// You can disable IDFA collecting by using this property. Make sure you call it before `.activate()` method.
    public static var idfaCollectionDisabled: Bool {
        get {
            Configuration.idfaCollectionDisabled
        }
        set {
            Configuration.idfaCollectionDisabled = newValue
        }
    }
}
