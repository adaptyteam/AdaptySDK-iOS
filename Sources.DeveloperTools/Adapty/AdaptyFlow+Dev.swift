//
//  AdaptyFlow+Dev.swift
//  Adapty
//
//  Created by Alex Goncharov on 20.05.2026.
//

import Adapty

public extension AdaptyFlow {
    var dev_countPaywalls: Int { paywalls.count }
}

public extension Adapty {
    nonisolated static func dev_openWebPaywall(
        flow: AdaptyFlow,
        paywallIndex: Int,
        in presentation: AdaptyWebPresentation
    ) async throws(AdaptyError) {
        try await Adapty.openWebPaywall(
            for: flow.paywalls[paywallIndex],
            in: presentation
        )
    }
}
