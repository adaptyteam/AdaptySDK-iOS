//
//  AnyCodingKey.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 05.12.2025.
//

struct AnyCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?

    init(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    init?(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
    }
}

extension AnyCodingKey {
    init(_ string: String) {
        self.init(stringValue: string)
    }
}
