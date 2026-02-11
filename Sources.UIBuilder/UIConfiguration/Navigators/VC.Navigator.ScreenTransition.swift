//
//  VC.Navigator.ScreenTransition.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 11.02.2026.
//

import Foundation

package extension VC.Navigator {
    struct ScreenTransition: Sendable, Hashable {
        package let outgoing: [VC.Animation]?
        package let incoming: [VC.Animation]?
        package let isIncomingOnTop: Bool
    }
}

package extension VC.Navigator.ScreenTransition {
    var isEmpty: Bool {
        (outgoing?.isEmpty ?? true) && (incoming?.isEmpty ?? true)
    }

    var isNotEmpty: Bool {
        !isEmpty
    }
}

package extension [String: VC.Navigator.ScreenTransition] {
    var forward: VC.Navigator.ScreenTransition? {
        self["forward"]
    }

    var backward: VC.Navigator.ScreenTransition? {
        self["backward"]
    }
}
