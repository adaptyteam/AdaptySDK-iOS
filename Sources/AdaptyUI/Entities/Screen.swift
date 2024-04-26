//
//  Screen.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension AdaptyUI {
    package struct Screen {
        static let `default` = Screen(
            background: .color(AdaptyUI.Color.black),
            mainImage: nil,
            mainBlock: nil,
            footerBlock: nil
        )
        package let background: AdaptyUI.Filling
        package let mainImage: Image?
        package let mainBlock: Element?
        package let footerBlock: Element?
    }
}
