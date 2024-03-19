//
//  AnyEncodable.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.09.2022.
//

import Foundation

struct AnyEncodable: Encodable {
    private let encodable: Encodable

    init(_ encodable: Encodable) {
        self.encodable = encodable
    }

    func encode(to encoder: Encoder) throws {
        try encodable.encode(to: encoder)
    }

    static func value(_ encodable: some Encodable) -> AnyEncodable {
        AnyEncodable(encodable)
    }

    static func valueOrNil(_ encodable: (some Encodable)?) -> AnyEncodable? {
        guard let encodable else { return nil }
        return AnyEncodable(encodable)
    }
}
