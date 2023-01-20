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
        public let value: String?
        public let size: Double?
        public let color: AdaptyUI.Color?
    }
}
