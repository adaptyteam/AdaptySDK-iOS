//
//  VC.ScreenActions.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 18.02.2026.
//

import Foundation

package extension VC {
    struct ScreenActions: Sendable, Hashable {
        package let onOutsideTap: [Action]?
        package let onSystemBack: [Action]?
    }
}
