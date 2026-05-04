//
//  VC.ScreenActions.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 18.02.2026.
//

import Foundation

extension VC {
    struct ScreenActions: Sendable {
        let onOutsideTap: [Action]?
        let onDeviceBack: [Action]?
        let onFocusChange: [Action]?

        let onWillAppear: [Action]?
        let onWillDisappear: [Action]?
        let onDidAppear: [Action]?
        let onDidDisappear: [Action]?
    }
}

