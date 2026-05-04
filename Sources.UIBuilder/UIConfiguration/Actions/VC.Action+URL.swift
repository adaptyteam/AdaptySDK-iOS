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

    var asURL: URL? {
        var components = URLComponents()
        components.scheme = Self.scheme
        components.host = [scope.rawValue, Self.host].joined(separator: ".")
        components.path = "/" + path.joined(separator: "/")

        guard let params, !params.isEmpty else {
            return components.url
        }

        components.queryItems = params
            .sorted(by: { $0.key < $1.key })
            .flatMap { $0.value.asQueryItems(name: $0.key) }

        return components.url
    }

    init(
        url: URL,
        autodetectType: Bool = false
    ) throws {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: [],
                    debugDescription: "wrong url: \(url)"
                )
            )
        }

        guard components.scheme == Self.scheme else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: [],
                    debugDescription: "wrong schema of url: \(url) use: \(Self.scheme)"
                )
            )
        }

        guard let rawValue = components.host?.split(separator: ".").first.map(String.init),
              let scope = VC.Scope(rawValue: rawValue)
        else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: [],
                    debugDescription:
                    "wrong host, unknown scope of action: \(components.host ?? "nil")"
                )
            )
        }

        self.scope = scope
        let path = components.path.split(separator: "/").map(String.init)

        guard !path.isEmpty else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: [],
                    debugDescription: "wrong function name in path of url: \(url)"
                )
            )
        }

        self.path = path

        guard let queryItems = components.queryItems, !queryItems.isEmpty else {
            self.params = nil
            return
        }

        var params = [String: VC.AnyValue]()
        for item in queryItems {
            let (fullPath, suffix) = item.name.extractSuffix()
            let path = fullPath.split(separator: ".").map(String.init)

            let value =
                if autodetectType {
                    (try? VC.AnyValue(key: fullPath, suffix: suffix, value: item.value))
                        ?? VC.AnyValue(string: item.value)
                } else {
                    try VC.AnyValue(key: fullPath, suffix: suffix, value: item.value)
                }
            params.setParameter(value, for: path)
        }
        self.params = params
    }
}

private enum Suffix: String, CaseIterable {
    case string = "_s"
    case bool = "_b"
    case int = "_i"
    case uint = "_u"
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

private extension VC.AnyValue {
    func asQueryItems(name: String) -> [URLQueryItem] {
        if wrapped.isNil {
            return [URLQueryItem(name: name, value: nil)]
        }
        if let value = wrapped as? String {
            return [URLQueryItem(name: name + Suffix.string.rawValue, value: value)]
        }
        if let value = wrapped as? Bool {
            return [URLQueryItem(name: name + Suffix.bool.rawValue, value: value.description)]
        }
        if let value = wrapped as? Int {
            return [URLQueryItem(name: name + Suffix.int.rawValue, value: value.description)]
        }
        if let value = wrapped as? UInt {
            return [URLQueryItem(name: name + Suffix.uint.rawValue, value: value.description)]
        }
        if let value = wrapped as? Double {
            return [URLQueryItem(name: name + Suffix.double.rawValue, value: value.description)]
        }
        if let dict = wrapped.asObject {
            return dict
                .sorted(by: { $0.key < $1.key })
                .flatMap { VC.AnyValue($0.value).asQueryItems(name: "\(name).\($0.key)") }
        }

        return []
    }

    init(
        key: String,
        suffix: Suffix?,
        value: String?
    ) throws {
        guard let value else {
            wrapped = String?.none
            return
        }

        guard let suffix else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: [],
                    debugDescription: "key: \(key) without suffix specified"
                )
            )
        }

        switch suffix {
        case .string:
            wrapped = value
        case .bool:
            guard let v = Bool(value) else {
                throw DecodingError.dataCorrupted(
                    .init(
                        codingPath: [],
                        debugDescription:
                        "value is wrong type for key: \(key)\(suffix.rawValue) = \(value) "
                    )
                )
            }
            wrapped = v
        case .int:
            guard let v = Int32(value) else {
                throw DecodingError.dataCorrupted(
                    .init(
                        codingPath: [],
                        debugDescription:
                        "value is wrong type for key: \(key)\(suffix.rawValue) = \(value) "
                    )
                )
            }
            wrapped = v
        case .uint:
            guard let v = UInt32(value) else {
                throw DecodingError.dataCorrupted(
                    .init(
                        codingPath: [],
                        debugDescription:
                        "value is wrong type for key: \(key)\(suffix.rawValue) = \(value) "
                    )
                )
            }
            wrapped = v
        case .double:
            guard let v = Double(value) else {
                throw DecodingError.dataCorrupted(
                    .init(
                        codingPath: [],
                        debugDescription:
                        "value is wrong type for key: \(key)\(suffix.rawValue) = \(value) "
                    )
                )
            }
            wrapped = v
        }
    }

    init(string: String?) {
        guard let string else {
            wrapped = String?.none
            return
        }

        if let boolValue = Bool(string) {
            wrapped = boolValue
        } else if let intValue = Int(string) {
            wrapped = intValue
        } else if let uintValue = UInt(string) {
            wrapped = uintValue
        } else if let doubleValue = Double(string) {
            wrapped = doubleValue
        } else {
            wrapped = string
        }
    }
}

private extension [String: VC.AnyValue] {
    mutating func setParameter(_ value: VC.AnyValue, for path: [String]) {
        guard !path.isEmpty else { return }
        let key = path[0]
        if path.count == 1 {
            self[key] = value
        } else {
            var subParams: [String: VC.AnyValue] =
                if let existing = self[key]?.asObject {
                    existing.mapValues(VC.AnyValue.init)
                } else {
                    [:]
                }
            subParams.setParameter(value, for: Array(path.dropFirst()))
            self[key] = VC.AnyValue(subParams)
        }
    }
}

