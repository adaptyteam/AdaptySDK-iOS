//
//  VC.Action+URL.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 17.12.2025.
//

import Foundation

extension VC.Action {
    private static let scheme = "sdk"
    private static let host = "action"

    package var asURL: URL? {
        var components = URLComponents()
        components.scheme = Self.scheme
        components.host = [scope.rawValue, Self.host].joined(separator: ".")
        components.path = "/" + path.joined(separator: "/")

        guard let params, !params.isEmpty else {
            return components.url
        }

        components.queryItems =
            params
            .sorted(by: { $0.key < $1.key })
            .flatMap { $0.value.asQueryItems(name: $0.key) }

        return components.url
    }

    package init(
        url: URL,
        autodetectType: Bool = false
    ) throws {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: [],
                    debugDescription: "wrong url: \(url)"
                ))
        }

        guard components.scheme == Self.scheme else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: [],
                    debugDescription: "wrong schema of url: \(url) use: \(Self.scheme)"
                ))
        }

        guard let rawValue = components.host?.split(separator: ".").first.map(String.init),
            let scope = VC.Scope(rawValue: rawValue)
        else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: [],
                    debugDescription:
                        "wrong host, unknown scope of action: \(components.host ?? "nil")"
                ))
        }

        self.scope = scope
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

        var params = [String: VC.Parameter]()
        for item in queryItems {
            let (fullPath, suffix) = item.name.extractSuffix()
            let path = fullPath.split(separator: ".").map(String.init)

            let value: VC.Parameter =
                if autodetectType {
                    (try? VC.Parameter(key: fullPath, suffix: suffix, value: item.value))
                        ?? VC.Parameter(string: item.value)
                } else {
                    try VC.Parameter(key: fullPath, suffix: suffix, value: item.value)
                }
            params.setParameter(value, for: path)
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

extension String {
    fileprivate func extractSuffix() -> (String, Suffix?) {
        for suffix in Suffix.allCases {
            let raw = suffix.rawValue
            guard hasSuffix(raw) else { continue }
            return (String(dropLast(raw.count)), suffix)
        }
        return (self, nil)
    }
}

extension VC.Parameter {
    fileprivate func asQueryItems(name: String) -> [URLQueryItem] {
        switch self {
        case .null:
            [URLQueryItem(name: name, value: nil)]
        case .string(let value):
            [URLQueryItem(name: name + Suffix.string.rawValue, value: value)]
        case .bool(let value):
            [URLQueryItem(name: name + Suffix.bool.rawValue, value: value.description)]
        case .int32(let value):
            [URLQueryItem(name: name + Suffix.int32.rawValue, value: value.description)]
        case .uint32(let value):
            [URLQueryItem(name: name + Suffix.uint32.rawValue, value: value.description)]
        case .double(let value):
            [URLQueryItem(name: name + Suffix.double.rawValue, value: value.description)]
        case .object(let dict):
            dict
                .sorted(by: { $0.key < $1.key })
                .flatMap { $0.value.asQueryItems(name: "\(name).\($0.key)") }
        }
    }

    fileprivate init(
        key: String,
        suffix: Suffix?,
        value: String?
    ) throws {
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
                        codingPath: [],
                        debugDescription:
                            "value is wrong type for key: \(key)\(suffix.rawValue) = \(value) "
                    ))
            }
            self = .bool(v)
        case .int32:
            guard let v = Int32(value) else {
                throw DecodingError.dataCorrupted(
                    .init(
                        codingPath: [],
                        debugDescription:
                            "value is wrong type for key: \(key)\(suffix.rawValue) = \(value) "
                    ))
            }
            self = .int32(v)
        case .uint32:
            guard let v = UInt32(value) else {
                throw DecodingError.dataCorrupted(
                    .init(
                        codingPath: [],
                        debugDescription:
                            "value is wrong type for key: \(key)\(suffix.rawValue) = \(value) "
                    ))
            }
            self = .uint32(v)
        case .double:
            guard let v = Double(value) else {
                throw DecodingError.dataCorrupted(
                    .init(
                        codingPath: [],
                        debugDescription:
                            "value is wrong type for key: \(key)\(suffix.rawValue) = \(value) "
                    ))
            }
            self = .double(v)
        }
    }

    fileprivate init(string: String?) {
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

extension [String: VC.Parameter] {
    fileprivate mutating func setParameter(_ value: VC.Parameter, for path: [String]) {
        guard !path.isEmpty else { return }
        let key = path[0]
        if path.count == 1 {
            self[key] = value
        } else {
            var subParams: [String: VC.Parameter] =
                if case .object(let existing) = self[key] {
                    existing
                } else {
                    [:]
                }
            subParams.setParameter(value, for: Array(path.dropFirst()))
            self[key] = .object(subParams)
        }
    }
}
