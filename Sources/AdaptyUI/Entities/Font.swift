//
//  Asset.Font.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.01.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

import Foundation

extension AdaptyUI {
    public struct Font {
        public let name: String
        public let style: String
        public let defaultSize: Double?
        public let defaultColor: AdaptyUI.Color?
        public let defaultHorizontalAlign: AdaptyUI.HorizontalAlign?
    }
}

extension AdaptyUI.Font {
    var defaultFilling: AdaptyUI.Filling? {
        guard let color = defaultColor else { return nil }
        return .color(color)
    }
}
