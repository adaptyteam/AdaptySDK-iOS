//
//  VC.Navigator.AppearanceTransition.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 11.02.2026.
//

import Foundation

package extension VC.Navigator {
    struct AppearanceTransition: Sendable, Hashable {
        package let background: VC.Animation.Background?
        package let content: [VC.Animation]?
    }
}

package extension VC.Navigator.AppearanceTransition {
    static let onDisappearKey = "on_disappear"
    static let onAppearKey = "on_appear"

    var isEmpty: Bool {
        background == nil && (content?.isEmpty ?? true)
    }

    var isNotEmpty: Bool {
        !isEmpty
    }
}

package extension [String: VC.Navigator.AppearanceTransition] {
    var onAppear: VC.Navigator.AppearanceTransition? {
        self[VC.Navigator.AppearanceTransition.onAppearKey]
    }

    var onDisappear: VC.Navigator.AppearanceTransition? {
        self[VC.Navigator.AppearanceTransition.onDisappearKey]
    }
}
