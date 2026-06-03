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
        case onboarding
        case uischema
    }
}

extension Cache.ItemType {
    @inlinable
    var schemaVersion: Int {
        switch self {
        case .flow: 1
        case .onboarding: 1
        case .uischema:
            if Adapty.uiBuilderVersion == "5_0" { 1 } else { 2 }
        }
    }
}

