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

extension Schema.Condition: DecodableWithConfiguration {
    enum CodingKeys: String, CodingKey {
        case metric
        case min
        case max
        case orientation
        case devices = "device"
        case platforms = "platform"
        case startVersion = "version"
        case endVersion = "to_version"
        case available
    }

    init(from decoder: Decoder, configuration: Schema.InternalDecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let device = configuration.device

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
            if min == nil, max == nil {
                self = .true
            } else {
                self = .condition(condition)
            }
        } else if container.contains(.orientation) {
            let orientation = try container.decode(Schema.Orientation.self, forKey: .orientation)
            self = .condition(.orientation(orientation))
        } else if container.contains(.platforms) {
            let platforms = try container.decode([String].self, forKey: .platforms)
            self = platforms.contains(Schema.platform) ? .true : .false
        } else if container.contains(.devices) {
            let devices = try container.decode([String].self, forKey: .devices)
            self = devices.contains(device.rawValue) ? .true : .false
        } else if container.contains(.startVersion) || container.contains(.endVersion) {
            var result = true
            if let startVersion = try container.decodeIfPresent(String.self, forKey: .startVersion) {
                result = Schema.formatVersion.isSameOrNewerVersion(than: startVersion)
            }
            if result, let endVersion = try container.decodeIfPresent(String.self, forKey: .endVersion) {
                result = !endVersion.isSameOrNewerVersion(than: Schema.formatVersion)
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

extension Schema.Condition {
    struct AvailableEntry: Decodable {
        static let currentOSName: String? = {
            #if os(visionOS)
            return "visionOS" // VisionOS should come before iOS—it also has true os(iOS) in zippered targets.
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
            return .init(
                majorVersion: parts[0],
                minorVersion: parts[1],
                patchVersion: 0
            )
        }
    }
}

extension [Schema.Condition.AvailableEntry] {
    var isSatisfied: Bool {
        guard
            let current = Schema.Condition.AvailableEntry.currentOSName,
            let entry = first(where: { $0.osName == current }),
            let version = entry.requiredVersion
        else { return true }
        return ProcessInfo.processInfo.isOperatingSystemAtLeast(version)
    }
}

