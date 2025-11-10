//
//  AdaptyPaywall+UIBuilder.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 22.09.2025.
//

import AdaptyUIBuilder
import Foundation

extension AdaptyUIBuilder {
    static func sendImageUrlsToObserver(_ paywall: AdaptyPaywall) {
        guard let viewConfiguration = paywall.viewConfiguration else { return }
        guard case let .unpacked(schema) = viewConfiguration.schemaOrJson else { return }
        sendImageUrlsToObserver(schema, forLocalId: viewConfiguration.locale.id)
    }
}
