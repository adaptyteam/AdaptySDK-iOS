//
//  Screen.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension AdaptyUI {
    public struct Screen {
        static let `default` = Screen(
            background: .color(AdaptyUI.Color.black),
            mainImage: nil,
            mainBlock: nil,
            footerBlock: nil
        )
        public let background: AdaptyUI.Filling
        public let mainImage: Image?
        public let mainBlock: Stack?
        public let footerBlock: Stack?
    }
}
