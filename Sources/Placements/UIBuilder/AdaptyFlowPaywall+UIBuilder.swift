//
//  AdaptyFlowPaywall+UIBuilder.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 22.09.2025.
//

import AdaptyUIBuilder
import Foundation

extension AdaptyUIBuilder {
    static func sendImageUrlsToObserver(_ flow: AdaptyFlow) {
        guard let viewConfiguration = flow.viewConfiguration else { return }
        guard case let .unpacked(schema) = viewConfiguration.source else { return }
        sendImageUrlsToObserver(schema, forLocalId: nil)
    }
}

