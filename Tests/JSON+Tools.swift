//
//  JSON+Tools.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 07.02.2026.
//

import Foundation

struct Json: Sendable, Hashable, CustomStringConvertible, CustomDebugStringConvertible {
    let data: Data

    private init(data: Data) {
        self.data = data
    }

    init(deserilized: Any, file: StaticString = #file, line: UInt = #line) {
        let data: Data
        do {
            data = try JSONSerialization.data(
                withJSONObject: deserilized,
                options: [.fragmentsAllowed, .sortedKeys]
            )
        } catch {
            preconditionFailure("Failed to serialize JSON: \(deserilized)\n\nerror: \(error)", file: file, line: line)
        }
        self.init(data: data)
    }

    init(_ value: StaticString, file: StaticString = #file, line: UInt = #line) {
        let data = value.withUTF8Buffer { Data($0) }
        let deserilized: Any
        do {
            deserilized = try data.deserilized
        } catch {
            preconditionFailure(
                "Invalid JSON:\n\n \(String(describing: value))\n\nfile: \(file), line: \(line)\n" +
                #####"""
                
                Use json in Json(##"..."##) or Json(##""" ... """##)
                
                Examples:
                  [1,2]    -> Json(##"[1,2]"##)
                  {}       -> Json(##"{}"##)
                  null     -> Json(##"null"##)
                  55       -> Json(##"55"##)
                  55.125   -> Json(##"55.125"##)
                  ""       -> Json(##""""##)
                  "string" -> Json(##""string""##)
                  true     -> Json(##"true"##)
                  false    -> Json(##"false"##)
                
                Multiline example: Json(##"""
                  {
                    "array": [ 1, 2, 3, 4],
                    "name": "Aleksei",
                    "pi": 3.1415,
                    "result": true
                  }
                """##)
                
                
                """##### +
                "error: \(error)",
                file: file,
                line: line
            )
        }
        self.init(deserilized: deserilized, file: file, line: line)
    }

    var deserilized: Any {
        get throws {
            try data.deserilized
        }
    }

    var debugDescription: String {
        guard let deserilized = try? data.deserilized,
              let prettyData = try? JSONSerialization.data(
                  withJSONObject: deserilized,
                  options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes, .fragmentsAllowed]
              ),
              let string = String(data: prettyData, encoding: .utf8)
        else {
            return description
        }
        return string
    }

    var description: String {
        String(data: data, encoding: .utf8) ?? "<invalid UTF-8>"
    }

    func decode<T: Decodable>(_ type: T.Type) throws -> T {
        try JSONDecoder().decode(type, from: data)
    }

    static func encode(_ value: some Encodable) throws -> Json {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return try Json(data: encoder.encode(value))
    }
}

private extension Data {
    var deserilized: Any {
        get throws {
            try JSONSerialization.jsonObject(with: self, options: [.fragmentsAllowed, .json5Allowed])
        }
    }
}

func rawValueToJson<Value>(_ array: [(value: Value, rawValue: some Any)], file: StaticString = #file, line: UInt = #line) -> [(value: Value, json: Json)] {
    array.map { value, raw in
        (value: value, json: Json(deserilized: raw, file: file, line: line))
    }
}

func rawValueToJson(_ array: [some Any], file: StaticString = #file, line: UInt = #line) -> [Json] {
    array.map { raw in
        Json(deserilized: raw, file: file, line: line)
    }
}
