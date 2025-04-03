//
//  AdaptyPaywallChosen.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 26.03.2024
//

import Foundation

enum AdaptyPaywallChosen: Sendable {
    case restore(AdaptyPaywall)
    case draw(AdaptyPaywallVariations.Draw)
}

extension AdaptyPaywallChosen {
    var paywall: AdaptyPaywall {
        switch self {
        case .restore(let paywall):
            paywall
        case .draw(let draw):
            draw.paywall
        }
    }
}
