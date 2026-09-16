//
//  JsonPath+Tools.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 07.02.2026.
//

import Foundation

enum JsonPathError: Error, CustomStringConvertible {
    case invalidPath(String)
    case pathNotFound(String)

    var description: String {
        switch self {
        case let .invalidPath(path): "Invalid JSON Path: \(path)"
        case let .pathNotFound(path): "Path not found: \(path)"
        }
    }
}

func resolveJSONPath(_ path: String, from: Any) throws -> Any {
    guard path.isEmpty || path.unicodeScalars.first == "/" else {
        throw JsonPathError.invalidPath(path)
    }

    let tokens = try path.unicodeScalars.split(separator: "/", omittingEmptySubsequences: false).dropFirst().map { token in
        var decoded = String.UnicodeScalarView()
        var scalars = token.makeIterator()
        while let scalar = scalars.next() {
            if scalar == "~" {
                switch scalars.next() {
                case "0": decoded.append("~")
                case "1": decoded.append("/")
                default: throw JsonPathError.invalidPath(path)
                }
            } else {
                decoded.append(scalar)
            }
        }
        return String(decoded)
    }

    var value = from
    for token in tokens {
        if let object = value as? NSDictionary {
            // JSON Pointer compares code points without Unicode normalization.
            guard let entry = object.first(where: {
                ($0.key as? String)?.unicodeScalars.elementsEqual(token.unicodeScalars) == true
            }) else {
                throw JsonPathError.pathNotFound(path)
            }
            value = entry.value
        } else if let array = value as? [Any] {
            guard !token.isEmpty,
                  token == "0" || !token.hasPrefix("0"),
                  token.utf8.allSatisfy({ (48 ... 57).contains($0) }),
                  let index = Int(token),
                  array.indices.contains(index)
            else {
                throw JsonPathError.pathNotFound(path)
            }
            value = array[index]
        } else {
            throw JsonPathError.pathNotFound(path)
        }
    }
    return value
}

extension Json {
    func deserilized(jsonPath path: String) throws -> Any {
        try resolveJSONPath(path, from: deserilized)
    }
}

extension [String: Any] {
    func resolve(jsonPath path: String) throws -> Any {
        try resolveJSONPath(path, from: self)
    }
}

extension [Any] {
    func resolve(jsonPath path: String) throws -> Any {
        try resolveJSONPath(path, from: self)
    }
}
