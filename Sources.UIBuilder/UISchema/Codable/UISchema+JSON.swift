//
//  JSONDecoder.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 23.09.2025.
//

import Foundation

package extension AdaptyUISchema {
    static var jsonDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dataDecodingStrategy = .base64
        return decoder
    }

    init(from jsonData: Data) throws {
        self = try AdaptyUISchema.jsonDecoder.decode(AdaptyUISchema.self, from: jsonData)
    }

    init(from jsonData: String) throws {
        try self.init(from: jsonData.data(using: .utf8) ?? Data())
    }
}
