//
//  AdaptyJsonString.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 07.11.2024.
//

import Foundation

public typealias AdaptyJsonString = String

public extension AdaptyJsonString {
    @inlinable
    var asAdaptyJsonData: Data {
        data(using: .utf8) ?? Data()
    }

    @inlinable
    func decode<T: Decodable>(_ valueType: T.Type) throws -> T {
        try asAdaptyJsonData.decode(valueType)
    }
}
