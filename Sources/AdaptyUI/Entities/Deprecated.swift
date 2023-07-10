//
//  Deprecated.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 10.07.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

import Foundation

extension AdaptyUI {
    @available(*, deprecated, renamed: "TextItems")
    public typealias TextRows = TextItems
    @available(*, deprecated, renamed: "Text")
    public typealias TextRow = Text
}

extension AdaptyUI.TextItems {
    @available(*, deprecated, renamed: "items")
    public var rows: [AdaptyUI.Text] { items }
}

extension AdaptyUI.LocalizedViewItem {
    @available(*, deprecated, renamed: "asTextItems")
    public var asTextRows: AdaptyUI.TextItems? { asTextItems }
}

extension Dictionary where Key == String, Value == AdaptyUI.LocalizedViewItem {
    @available(*, deprecated, renamed: "getTextItems")
    public func getTextRows(_ key: Key) -> AdaptyUI.TextItems? { getTextItems(key) }
}

extension AdaptyUI.Shape {
    @available(*, deprecated, renamed: "AdaptyUI.ShapeType")
    public typealias Mask = AdaptyUI.ShapeType
    @available(*, deprecated, renamed: "type")
    public var mask: AdaptyUI.ShapeType { type }
}
