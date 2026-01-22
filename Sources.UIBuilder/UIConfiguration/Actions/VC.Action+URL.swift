//
//  VC.Action+URL.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 17.12.2025.
//

import Foundation

package extension VC.Action {
    private static let scheme = "sdk"
    private static let host = "action"

    var asURL: URL? {
        var components = URLComponents()
        components.scheme = Self.scheme
        components.host = [context.rawValue, Self.host].joined(separator: ".")
        components.path = "/" + path.joined(separator: "/")

        guard let params, !params.isEmpty else {
            return components.url
        }

        components.queryItems =
            params
                .sorted(by: { $0.key < $1.key })
                .map { URLQueryItem(name: $0.key + ($0.value.keySuffix?.rawValue ?? ""), value: $0.value.asQueryValue) }

        return components.url
    }

    init(url: URL, autodetectType: Bool = false) throws {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: [], debugDescription: "wrong url: \(url)"))
        }

        guard components.scheme == Self.scheme else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: [], debugDescription: "wrong schema of url: \(url) use: \(Self.scheme)"))
        }

        guard let rawValue = components.host?.split(separator: ".").first.map(String.init),
              let context = VC.Context(rawValue: rawValue) else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: [], debugDescription: "wrong host, unknown context of action: \(components.host ?? "nil")"))
        }

        self.context = context
        let path = components.path.split(separator: "/").map(String.init)

        guard !path.isEmpty else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: [], debugDescription: "wrong function name in path of url: \(url)"
                ))
        }

        self.path = path

        guard let queryItems = components.queryItems, !queryItems.isEmpty else {
            self.params = nil
            return
        }

        var params = [String: Parameter]()
        for item in queryItems {
            let (key, suffix) = item.name.extractSuffix()
            if autodetectType {
                params[key] = (try? Parameter(key: key, suffix: suffix, value: item.value)) ?? Parameter(string: item.value)
            } else {
                params[key] = try Parameter(key: key, suffix: suffix, value: item.value)
            }
        }
        self.params = params
    }
}

private enum Suffix: String, CaseIterable {
    case string = "_s"
    case bool = "_b"
    case int32 = "_i32"
    case uint32 = "_u32"
    case double = "_d"
}

private extension String {
    func extractSuffix() -> (String, Suffix?) {
        for suffix in Suffix.allCases {
            let raw = suffix.rawValue
            guard hasSuffix(raw) else { continue }
            return (String(dropLast(raw.count)), suffix)
        }
        return (self, nil)
    }
}

private extension VC.Action.Parameter {
    var keySuffix: Suffix? {
        switch self {
        case .null: nil
        case .string: .string
        case .bool: .bool
        case .int32: .int32
        case .uint32: .uint32
        case .double: .double
        }
    }

    var asQueryValue: String? {
        switch self {
        case .null: nil
        case .string(let s): s
        case .bool(let b): b.description
        case .int32(let i): i.description
        case .uint32(let u): u.description
        case .double(let d): d.description
        }
    }

    init(key: String, suffix: Suffix?, value: String?) throws {
        guard let value else {
            self = .null
            return
        }

        guard let suffix else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: [], debugDescription: "key: \(key) without suffix specified"
                ))
        }

        switch suffix {
        case .string:
            self = .string(value)
        case .bool:
            guard let v = Bool(value) else {
                throw DecodingError.dataCorrupted(
                    .init(
                        codingPath: [], debugDescription: "value is wrong type for key: \(key)\(suffix.rawValue) = \(value) "
                    ))
            }
            self = .bool(v)
        case .int32:
            guard let v = Int32(value) else {
                throw DecodingError.dataCorrupted(
                    .init(
                        codingPath: [], debugDescription: "value is wrong type for key: \(key)\(suffix.rawValue) = \(value) "
                    ))
            }
            self = .int32(v)
        case .uint32:
            guard let v = UInt32(value) else {
                throw DecodingError.dataCorrupted(
                    .init(
                        codingPath: [], debugDescription: "value is wrong type for key: \(key)\(suffix.rawValue) = \(value) "
                    ))
            }
            self = .uint32(v)
        case .double:
            guard let v = Double(value) else {
                throw DecodingError.dataCorrupted(
                    .init(
                        codingPath: [], debugDescription: "value is wrong type for key: \(key)\(suffix.rawValue) = \(value) "
                    ))
            }
            self = .double(v)
        }
    }

    init(string: String?) {
        guard let string else {
            self = .null
            return
        }

        if let boolValue = Bool(string) {
            self = .bool(boolValue)
        } else if let intValue = Int32(string) {
            self = .int32(intValue)
        } else if let uintValue = UInt32(string) {
            self = .uint32(uintValue)
        } else if let doubleValue = Double(string) {
            self = .double(doubleValue)
        } else {
            self = .string(string)
        }
    }
}
