//
//  Cache.ItemType.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.05.2026.
//

import Foundation

extension Cache {
    enum ItemType: String, Hashable, Sendable, Codable, CaseIterable {
        case flow
        case flowLayout = "flow_layout"
        case flowVariants = "flow_variants"
        case onboarding
        case onboardingVariants = "onboarding_variants"
    }
}

extension Cache.ItemType {
    @inlinable
    var schemaVersion: Int {
        switch self {
        case .flow, .flowVariants: 1
        case .flowLayout: 1
        case .onboarding, .onboardingVariants: 1
        }
    }
}
