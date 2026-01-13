//
//  VC.Screen.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

package extension VC {
    struct Screen: Sendable, Hashable {
        package let templateId: String
        package let background: AssetReference?
        package let cover: Box?
        package let content: Element
        package let footer: Element?
        package let overlay: Element?
    }
}
