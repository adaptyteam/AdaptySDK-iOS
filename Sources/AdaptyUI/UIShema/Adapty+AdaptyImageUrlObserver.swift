//
//  Adapty+.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 22.09.2025.
//

import AdaptyUIBuider
import Foundation

extension AdaptyUIBuilder {
    static func sendImageUrlsToObserver(_ paywall: AdaptyPaywall) {
        guard let viewConfig = paywall.viewConfiguration else { return }
        guard case let .unpacked(schema) = viewConfig.schemaOrJson else { return }
        sendImageUrlsToObserver(schema, forLocalId: viewConfig.responseLocale.id)
    }
}
