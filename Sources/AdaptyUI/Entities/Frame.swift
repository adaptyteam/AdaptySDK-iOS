//
//  Frame.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

extension AdaptyUI {
    public struct Frame {
        public let height: Unit?
        public let width: Unit?
        public let minHeight: Unit?
        public let maxHeight: Unit?
        public let minWidth: Unit?
        public let maxWidth: Unit?
    }
}

extension AdaptyUI.Frame {
    public var isEmpty: Bool {
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
        case minHeight
        case maxHeight
        case minWidth
        case maxWidth
    }
}
