//
//  JSONSerialization+Extensions.swift
//  AdaptyCodable
//
//  Created by Aleksei Valiano on 27.07.2026.
//

import Foundation

package struct InvalidJsonObjectError: LocalizedError {
    let errorDescription = "Object data must be a valid JSON object."
}

package extension JSONSerialization {
    static func jsonData(from obj: Any, options: JSONSerialization.WritingOptions = []) throws -> Data {
        guard JSONSerialization.isValidJSONObject(obj) else {
            throw InvalidJsonObjectError()
        }

        return try JSONSerialization.data(withJSONObject: obj, options: options)
    }

    static func jsonString(from obj: Any, options opt: JSONSerialization.WritingOptions = []) throws -> String {
        let data = try jsonData(from: obj, options: opt)
        return String(decoding: data, as: UTF8.self)
    }
}
