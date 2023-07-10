//
//  TextItems.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.01.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

import Foundation

extension AdaptyUI {
    public struct TextItems {
        static let defaultSeparator = Text.Separator.none

        public let items: [Text]
        public let separator: Text.Separator
    }
}

extension AdaptyUI.Text {
    public enum Separator: String {
        case none
        case newline
    }
}

extension AdaptyUI.TextItems {
    var asText: AdaptyUI.Text? { items.first }
}
