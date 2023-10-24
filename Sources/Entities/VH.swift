//
//  VH.swift
//  Adapty
//
//  Created by Aleksei Valiano on 24.09.2022.
//

import Foundation

struct VH<T> {
    let value: T
    let hash: String?

    init(_ value: T, hash: String?) {
        self.value = value
        self.hash = hash
    }

    enum CodingKeys: String, CodingKey {
        case value = "v"
        case hash = "h"
    }
}

extension VH: Encodable where T: Encodable {}

extension VH: Decodable where T: Decodable {}
