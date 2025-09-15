//
//  AdaptyUIBuilder+Events.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 15.09.2025.
//

import AdaptyUIBuider

extension Adapty {
package static func logShowPaywall(_ paywall: AdaptyPaywall, viewConfiguration: AdaptyUIConfiguration) {
    trackEvent(.paywallShowed(.init(variationId: paywall.variationId, viewConfigurationId: viewConfiguration.id)))
}
}
