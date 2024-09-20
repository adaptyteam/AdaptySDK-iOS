//
//  AnyCodingKeys.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 05.04.2023
//

import Foundation

struct AnyCodingKeys: CodingKey {
    var stringValue: String
    var intValue: Int?

    init(stringValue: String) {
        self.stringValue = stringValue
    }

    init?(intValue: Int) {
        self.init(stringValue: "\(intValue)")
        self.intValue = intValue
    }
}
