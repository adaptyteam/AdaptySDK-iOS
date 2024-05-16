//
//  Screen.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension AdaptyUI {
    package struct Screen {
        static let defaultBackground: AdaptyUI.Filling = .color(AdaptyUI.Color.black)

        package let background: AdaptyUI.Filling
        package let cover: Element?
        package let content: Element
        package let footer: Element?
        package let overlay: Element?
    }
}
