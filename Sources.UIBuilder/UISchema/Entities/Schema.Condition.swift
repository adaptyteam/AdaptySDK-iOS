//
//  Schema.Condition.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 04.06.2026.
//

import Foundation

extension Schema {
    enum Condition: Sendable {
        case condition(VC.Condition)
        case `true`
        case `false`
    }
}

private extension VC.Condition {
    var isAlwaysTrue: Bool {
        switch self {
        case let .availableWidth(min, max):
            min == nil && max == nil
        case let .availableHeight(min, max):
            min == nil && max == nil
        case let .screenWidth(min, max):
            min == nil && max == nil
        case let .screenHeight(min, max):
            min == nil && max == nil
        case .orientation: false
        }
    }
}

extension Schema.Condition {
    var isAlwaysTrue: Bool {
        if case .true = self { true } else { false }
    }

    var isAlwaysFalse: Bool {
        if case .false = self { true } else { false }
    }
}

extension [Schema.Condition] {
    var asConditions: [VC.Condition]? {
        var result = [VC.Condition]()
        result.reserveCapacity(count)
        for condition in self {
            switch condition {
            case let .condition(condition):
                if !condition.isAlwaysTrue {
                    result.append(condition)
                }
            case .true:
                break
            case .false:
                return nil
            }
        }
        return result
    }
}

//
// Condition:
//    title: Condition
//    description: "Predicate resolving to boolean; used by flex, flex_stack and switch"
//    oneOf:
//        - title: Size threshold
//          type: object
//          required: [metric]
//          properties:
//              metric:
//                  type: string
//                  enum:
//                      - available_width
//                      - available_height
//                      - screen_width
//                      - screen_height
//              min:
//                  type: number
//                  description: "Inclusive lower bound, in points"
//              max:
//                  type: number
//                  description: "Inclusive upper bound, in points"
//          additionalProperties: false
//        - title: Device type
//          type: object
//          required: [device]
//          properties:
//              device:
//                  title: "True when the device type matches at least one of the listed values"
//                  type: array
//                  minItems: 1
//                  items: { enum: [phone, tab] }
//          additionalProperties: false
//        - title: Screen orientation
//          type: object
//          required: [orientation]
//          properties:
//              orientation: { enum: [landscape, portrait] }
//          additionalProperties: false
//        - title: Platform
//          type: object
//          required: [platform]
//          properties:
//              platform:
//                  title: "True when the platform matches at least one of the listed values"
//                  type: array
//                  minItems: 1
//                  items: { enum: [ios, android] }
//          additionalProperties: false
//        - title: Version range
//          type: object
//          anyOf:
//              - required: [version]
//              - required: [to_version]
//          properties:
//              version:
//                  type: string
//                  pattern: "^[0-9]+(\\.[0-9]+){0,2}(-[A-Za-z0-9._]+)?$"
//                  description: "Minimum format version (inclusive, lower bound)"
//              to_version:
//                  type: string
//                  pattern: "^[0-9]+(\\.[0-9]+){0,2}(-[A-Za-z0-9._]+)?$"
//                  description: "Maximum format version (exclusive, upper bound)"
//          additionalProperties: false
//        - title: Available (per-OS minimum version)
//          type: object
//          required: [available]
//          properties:
//              available:
//                  type: array
//                  description: >
//                      Per-OS minimum-version constraints (semantics of Swift's
//                      @available). Each item declares the minimum (inclusive)
//                      runtime version required for the named OS. Operating
//                      systems NOT listed carry no constraint — true for them at
//                      any version. False only when the runtime OS is listed AND
//                      its version is below that item's os_version. Each os_name
//                      MUST appear at most once.
//                  items:
//                      type: object
//                      required: [os_name, os_version]
//                      properties:
//                          os_name:
//                              type: string
//                              description: "Operating system name to match against the runtime OS."
//                              enum:
//                                  - iOS
//                                  - macOS
//                                  - tvOS
//                                  - watchOS
//                                  - visionOS
//                                  - Android
//                          os_version:
//                              type: string
//                              pattern: "^[0-9]+\\.[0-9]+$"
//                              description: "Minimum runtime OS version (inclusive) required for this os_name."
//                      additionalProperties: false
//                  uniqueItems: true
//                  minItems: 1
//          additionalProperties: false

extension Schema.Condition: Decodable {
    enum CodingKeys: String, CodingKey {
        case metric
        case min
        case max
        case orientation
        case device
        case platform
        case version
        case toVersion = "to_version"
        case available
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.contains(.metric) {
            let metric = try container.decode(String.self, forKey: .metric)
            let min = try container.decodeIfPresent(Double.self, forKey: .min)
            let max = try container.decodeIfPresent(Double.self, forKey: .max)
            let condition: VC.Condition = switch metric {
            case "available_width": .availableWidth(min: min, max: max)
            case "available_height": .availableHeight(min: min, max: max)
            case "screen_width": .screenWidth(min: min, max: max)
            case "screen_height": .screenHeight(min: min, max: max)
            default:
                throw DecodingError.dataCorruptedError(forKey: .metric, in: container, debugDescription: "unknown metric: \(metric)")
            }
            if min == nil && max == nil {
                self = .true
            } else {
                self = .condition(condition)
            }
        } else if container.contains(.orientation) {
            let orientation = try container.decode(Schema.Orientation.self, forKey: .orientation)
            self = .condition(.orientation(orientation))
        } else if container.contains(.platform) {
            let platforms = try container.decode([String].self, forKey: .platform)
            self = platforms.contains("ios") ? .true : .false
        } else if container.contains(.device) {
            self = .true
        } else if container.contains(.version) || container.contains(.toVersion) {
            var result = true
            if let version = try container.decodeIfPresent(String.self, forKey: .version) {
                result = Schema.formatVersion.isSameOrNewerVersion(than: version)
            }
            if result, let toVersion = try container.decodeIfPresent(String.self, forKey: .toVersion) {
                result = !toVersion.isSameOrNewerVersion(than: Schema.formatVersion)
            }
            self = result ? .true : .false
        } else if container.contains(.available) {
            let entries = try container.decode([AvailableEntry].self, forKey: .available)
            self = entries.isSatisfied ? .true : .false
        } else {
            throw DecodingError.dataCorrupted(.init(
                codingPath: decoder.codingPath,
                debugDescription: "Condition must contain one of: metric, orientation, platform, device, version, to_version, available"
            ))
        }
    }
}

private extension Schema.Condition {
    struct AvailableEntry: Decodable {
        static let currentOSName: String? = {
            #if os(visionOS)
            return "visionOS"
            #elseif os(iOS)
            return "iOS"
            #elseif os(macOS)
            return "macOS"
            #elseif os(tvOS)
            return "tvOS"
            #elseif os(watchOS)
            return "watchOS"
            #else
            return nil
            #endif
        }()

        let osName: String
        let osVersion: String

        enum CodingKeys: String, CodingKey {
            case osName = "os_name"
            case osVersion = "os_version"
        }

        var requiredVersion: OperatingSystemVersion? {
            let parts = osVersion.split(separator: ".").compactMap { Int($0) }
            guard parts.count >= 2 else { return nil }
            return .init(majorVersion: parts[0], minorVersion: parts[1], patchVersion: 0)
        }
    }
}

private extension [Schema.Condition.AvailableEntry] {
    var isSatisfied: Bool {
        guard
            let current = Schema.Condition.AvailableEntry.currentOSName,
            let entry = first(where: { $0.osName == current }),
            let version = entry.requiredVersion
        else { return true }
        return ProcessInfo.processInfo.isOperatingSystemAtLeast(version)
    }
}

