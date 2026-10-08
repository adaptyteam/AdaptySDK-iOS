//
//  Schema.Value.swift
//  AdaptyUIBulder
//
//  Created by Aleksei Valiano on 13.04.2026.
//

import Foundation

extension Schema {
    typealias Value = VC.Value
}

extension Schema.Value: Decodable {
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self.init(String?.none)
            return
        }
        if let value = try? container.decode(Bool.self) {
            self.init(value)
            return
        }
        if let value = try? container.decode(Int.self) {
            self.init(value)
            return
        }
        if let value = try? container.decode(UInt.self) {
            self.init(value)
            return
        }
        if let value = try? container.decode(Double.self) {
            self.init(value)
            return
        }
        if let value = try? container.decode(String.self) {
            self.init(value)
            return
        }
        if let value = try? container.decode([Schema.Value].self) {
            self.init(value)
            return
        }
        if let value = try? container.decode([String: Schema.Value].self) {
            self.init(value)
            return
        }
        throw DecodingError.typeMismatch(
            Self.self,
            .init(
                codingPath: decoder.codingPath,
                debugDescription: "Unsupported Schema.Value type"
            )
        )
    }
}
