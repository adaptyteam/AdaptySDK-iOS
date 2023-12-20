//
//  Text.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.01.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

import Foundation

extension AdaptyUI {
    public struct Text {
        static let defaultHorizontalAlign = HorizontalAlign.left

        public let value: String?
        public let fallback: String?
        public let hasTags: Bool
        public let font: AdaptyUI.Font?
        public let size: Double?
        public let fill: AdaptyUI.Filling?
        public let horizontalAlign: AdaptyUI.HorizontalAlign
    }
}
