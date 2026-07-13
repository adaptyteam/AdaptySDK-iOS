//
//  VC.Navigator.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 30.01.2026.
//

import Foundation

extension VC {
    struct Navigator: Sendable {
        let id: NavigatorIdentifier
        let poolElements: [VC.Element]
        let background: AssetReference?
        let content: ElementIndex
        let order: Int
        let appearances: [String: AppearanceTransition]?
        let transitions: [String: ScreenTransition]?
        let defaultScreenActions: ScreenActions
    }
}
