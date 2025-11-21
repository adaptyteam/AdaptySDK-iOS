//
//  AdaptyServerKind.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 12.11.2025.
//

import Foundation

package enum AdaptyServerKind: Sendable, CaseIterable {
    case main
    case fallback
    case configs
    case ua
}
