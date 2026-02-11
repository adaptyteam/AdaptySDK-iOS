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
    var isEmpty: Bool {
        background == nil && (content?.isEmpty ?? true)
    }

    var isNotEmpty: Bool {
        !isEmpty
    }
}

package extension [String: VC.Navigator.AppearanceTransition] {
    var onAppear: VC.Navigator.AppearanceTransition? {
        self["on_appear"]
    }

    var onDisappear: VC.Navigator.AppearanceTransition? {
        self["on_disappear"]
    }
}
