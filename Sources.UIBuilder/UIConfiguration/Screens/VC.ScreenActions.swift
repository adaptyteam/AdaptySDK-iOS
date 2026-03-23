//
//  VC.ScreenActions.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 18.02.2026.
//

import Foundation

extension VC {
    struct ScreenActions: Sendable, Hashable {
        let onOutsideTap: [Action]?
        let onDeviceBack: [Action]?
        let onFocusChange: [Action]?
    }
}
