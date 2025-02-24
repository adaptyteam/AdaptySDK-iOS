//
//  AdaptyPaywallChosen.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 26.03.2024
//

import Foundation

enum AdaptyPaywallChosen: Sendable {
    case restore(AdaptyPaywall)
    case draw(AdaptyPaywall, profileId: String)
}

extension AdaptyPaywallChosen {
    static func draw(_ draw: AdaptyPaywallVariations.Draw) -> Self {
        .draw(draw.paywall, profileId: draw.profileId)
    }

    var paywall: AdaptyPaywall {
        switch self {
        case .restore(let paywall),
             .draw(let paywall, _):
            paywall
        }
    }
}
