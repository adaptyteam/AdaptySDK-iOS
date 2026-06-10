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
        case flowVariants = "flow_variants"
        case onboarding
        case onboardingVariants = "onboarding_variants"
        case uischema
    }
}

extension Cache.ItemType {
    @inlinable
    var schemaVersion: Int {
        switch self {
        case .flow, .flowVariants: 1
        case .onboarding, .onboardingVariants: 1
        case .uischema: 2
        }
    }
}

