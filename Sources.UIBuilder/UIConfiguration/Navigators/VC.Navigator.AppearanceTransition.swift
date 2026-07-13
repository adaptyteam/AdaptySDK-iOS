//
//  VC.Navigator.AppearanceTransition.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 11.02.2026.
//

import Foundation

extension VC.Navigator {
    struct AppearanceTransition: Sendable {
        let background: VC.Animation.Background?
        let content: [VC.Animation]?
    }
}

extension VC.Navigator.AppearanceTransition {
    static let onDisappearKey = "on_disappear"
    static let onAppearKey = "on_appear"

    @inlinable
    var isEmpty: Bool {
        background == nil && (content?.isEmpty ?? true)
    }

    @inlinable
    var isNotEmpty: Bool {
        !isEmpty
    }
}

extension [String: VC.Navigator.AppearanceTransition] {
    var onAppear: VC.Navigator.AppearanceTransition? {
        self[VC.Navigator.AppearanceTransition.onAppearKey]
    }

    var onDisappear: VC.Navigator.AppearanceTransition? {
        self[VC.Navigator.AppearanceTransition.onDisappearKey]
    }
}
