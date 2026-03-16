//
//  VC.Navigator.ScreenTransition.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 11.02.2026.
//

import Foundation

extension VC.Navigator {
    struct ScreenTransition: Sendable, Hashable {
        let outgoing: [VC.Animation]?
        let incoming: [VC.Animation]?
        let isIncomingOnTop: Bool
    }
}

extension VC.Navigator.ScreenTransition {
    @inlinable
    var isEmpty: Bool {
        (outgoing?.isEmpty ?? true) && (incoming?.isEmpty ?? true)
    }

    @inlinable
    var isNotEmpty: Bool {
        !isEmpty
    }
}

extension [String: VC.Navigator.ScreenTransition] {
    var forward: VC.Navigator.ScreenTransition? {
        self["forward"]
    }

    var backward: VC.Navigator.ScreenTransition? {
        self["backward"]
    }
}
