//
//  AdaptyPaywallChosen.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 26.03.2024
//

import Foundation

struct AdaptyPaywallChosen: Sendable {
    var value: AdaptyPaywall
    let kind: Kind

    enum Kind: Sendable, Hashable {
        case restore
        case draw(placementAudienceVersionId: String, profileId: String)
    }

    private init(_ value: AdaptyPaywall, _ kind: Kind) {
        self.value = value
        self.kind = kind
    }

    static func restored(_ paywall: AdaptyPaywall) -> Self {
        .init(paywall, .restore)
    }

    static func draw(_ draw: AdaptyPaywallVariations.Draw, _ paywall: AdaptyPaywall) -> Self {
        .init(paywall, .draw(placementAudienceVersionId: draw.placementAudienceVersionId, profileId: draw.profileId))
    }

    static func draw(_ profileId: String, _ paywall: AdaptyPaywall) -> Self {
        .init(paywall, .draw(placementAudienceVersionId: paywall.placementAudienceVersionId, profileId: profileId))
    }

    func replaceAdaptyPaywall(version: Int64) -> Self {
        var mutable = self
        mutable.value.version = version
        return mutable
    }
}
