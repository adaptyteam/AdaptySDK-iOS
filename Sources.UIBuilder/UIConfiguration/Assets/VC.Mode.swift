//
//  VC.Mode.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 30.08.2024
//
//

import Foundation

package extension VC {
    enum Mode: Sendable, Hashable {
        case light
        case dark
    }
}

extension VC.Mode {
    var suffix: String? {
        switch self {
        case .dark:
            "@dark"
        case .light:
            nil
        }
    }
}
