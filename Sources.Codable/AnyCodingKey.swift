//
//  AnyCodingKey.swift
//  AdaptyCodable
//
//  Created by Aleksei Valiano on 05.12.2025.
//

import Foundation

public struct AnyCodingKey: CodingKey {
    public var stringValue: String
    public var intValue: Int?

    public init(stringValue: String) {
        self.stringValue = stringValue
        intValue = nil
    }

    public init?(intValue: Int) {
        stringValue = String(intValue)
        self.intValue = intValue
    }
}

public extension AnyCodingKey {
    init(_ string: String) {
        self.init(stringValue: string)
    }

    init(_ value: any RawRepresentable<String>) {
        stringValue = value.rawValue
        intValue = nil
    }
}

