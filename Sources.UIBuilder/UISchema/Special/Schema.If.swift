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
            case devices = "device"
            case startVersion = "version"
            case endVersion = "to_version"
            case available
            case then
            case `else`
        }

        init(from decoder: Decoder, configuration: InternalDecodingConfiguration) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let device = configuration.device

            var result = try container.decodeIfPresent(String.self, forKey: .platform).map { $0 == Schema.platform } ?? true

            if result, let devices = try container.decodeIfPresent([String].self, forKey: .devices) {
                result = devices.contains(device.rawValue)
            }

            if result, let available = try container.decodeIfPresent([Schema.Condition.AvailableEntry].self, forKey: .available) {
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
