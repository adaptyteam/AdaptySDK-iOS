//
//  Schema.If.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension Schema {
    struct If: DecodableWithConfiguration {
        let content: Schema.Element

        enum CodingKeys: String, CodingKey {
            case platform
            case startVersion = "version"
            case endVersion = "to_version"
            case available
            case osName = "os_name"
            case osVersion = "os_version"
            case then
            case `else`
        }

        init(from decoder: Decoder, configuration: DecodingConfiguration) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            var result = try container.decodeIfPresent(String.self, forKey: .platform).map { $0 == "ios" } ?? true

            if result, let available = try container.decodeIfPresent([Schema.If.AvailableEntry].self, forKey: .available) {
                result = available.isSatisfied
            }

            if result, let startVersion = try container.decodeIfPresent(String.self, forKey: .startVersion) {
                result = Schema.formatVersion.isSameOrNewerVersion(than: startVersion)
            }

            if result, let endVersion = try container.decodeIfPresent(String.self, forKey: .endVersion) {
                result = !endVersion.isSameOrNewerVersion(than: Schema.formatVersion)
            }

            content = try container.decode(Schema.Element.self, forKey: result ? .then : .else, configuration: configuration)
        }
    }
}

private extension Schema.If {
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
            return .init(majorVersion: parts[0],
                         minorVersion: parts[1],
                         patchVersion: 0)
        }
    }
}

private extension [Schema.If.AvailableEntry] {
    var isSatisfied: Bool {
        guard
            let current = Schema.If.AvailableEntry.currentOSName,
            let entry = self.first(where: { $0.osName == current }),
            let version = entry.requiredVersion
        else { return true }
        return ProcessInfo.processInfo.isOperatingSystemAtLeast(version)
    }
}

