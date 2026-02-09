//
//  VC.Navigator.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 30.01.2026.
//

import Foundation

package extension VC {
    struct Navigator: Sendable, Hashable {
        package let id: NavigatorIdentifier
        package let background: AssetReference?
        package let content: Element
        package let order: Int
    }
}
