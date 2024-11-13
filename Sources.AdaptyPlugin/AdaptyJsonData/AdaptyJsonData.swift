//
//  AdaptyJsonData.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 07.11.2024.
//

import Foundation

public typealias AdaptyJsonData = Data

public extension AdaptyJsonData {
    @inlinable
    var asAdaptyJsonString: String {
        String(decoding: self, as: UTF8.self)
    }

    func decode<T: Decodable>(_ valueType: T.Type) throws -> T {
        try AdaptyPlugin.decoder.decode(valueType, from: self)
    }
}
