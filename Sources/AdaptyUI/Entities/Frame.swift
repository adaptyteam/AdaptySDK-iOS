//
//  Frame.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

extension AdaptyUI {
    package struct Frame {
        package let height: Unit?
        package let width: Unit?
        package let minHeight: Unit?
        package let maxHeight: Unit?
        package let minWidth: Unit?
        package let maxWidth: Unit?
    }
}

extension AdaptyUI.Frame {
    package var isEmpty: Bool {
        height == nil
            && width == nil
            && minHeight == nil
            && maxHeight == nil
            && minWidth == nil
            && maxWidth == nil
    }
}

extension AdaptyUI.Frame: Decodable {
    enum CodingKeys: String, CodingKey {
        case height
        case width
        case minHeight = "min_height"
        case maxHeight = "max_height"
        case minWidth = "min_width"
        case maxWidth = "max_width"
    }
}
