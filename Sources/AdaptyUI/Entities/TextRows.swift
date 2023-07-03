//
//  TextRows.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.01.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

import Foundation

extension AdaptyUI {
    public struct TextRows {
        public let font: AdaptyUI.Font?
        public let rows: [TextRow]
    }

    public struct TextRow {
        static let defaultHorizontalAlign = Text.defaultHorizontalAlign

        public let bullet: Image?
        public let value: String?
        public let size: Double?
        public let fill: AdaptyUI.Filling?
        public let horizontalAlign: AdaptyUI.HorizontalAlign
    }
}
