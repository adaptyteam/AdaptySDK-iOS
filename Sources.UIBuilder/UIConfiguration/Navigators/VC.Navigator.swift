//
//  VC.Navigator.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 30.01.2026.
//

import Foundation

extension VC {
    struct Navigator: Sendable, Hashable {
        let id: NavigatorIdentifier
        let background: AssetReference?
        let content: Element
        let order: Int
        let appearances: [String: AppearanceTransition]?
        let transitions: [String: ScreenTransition]?
        let defaultScreenActions: ScreenActions
    }
}
