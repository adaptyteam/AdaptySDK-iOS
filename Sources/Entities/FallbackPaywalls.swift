//
//  FallbackPaywalls.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 30.09.2022.
//

import Foundation

struct FallbackPaywalls {
    static var currentFormatVersion = 5

    private let source: Source
    let formatVersion: Int
    private let versionByPlacement: [String: Int64]

    func getPaywallVersion(byPlacmentId id: String) -> Int64 {
        versionByPlacement[id] ?? 0
    }

    func getPaywall(byPlacmentId id: String, profileId: String) -> AdaptyPaywallChosen? {
        let chosen: AdaptyPaywallChosen?

        do {
            chosen =
                switch source {
                case let .dataByPlacementId(value):
                    try FallbackPaywalls.getPaywall(byPlacmentId: id, profileId: profileId, from: value)
                case let .data(value):
                    try FallbackPaywalls.getPaywall(byPlacmentId: id, profileId: profileId, from: value)
                case .unknown:
                    nil
                }
        } catch {
            Log.error(error.localizedDescription)
            chosen = nil
        }

        return chosen.map {
            var v = $0
            v.value.version = versionByPlacement[id] ?? 0
            return v
        }
    }
}

private extension FallbackPaywalls {
    enum Source {
        case data(Data)
        case dataByPlacementId([String: Data])
        case unknown
    }

    private static func getPaywall(byPlacmentId id: String, profileId: String, from: [String: Data]) throws -> AdaptyPaywallChosen? {
        guard let data = from[id] else { return nil }
        let decoder = FallbackPaywalls.decoder(profileId: profileId)
        return try decoder.decode(AdaptyPaywallChosen.self, from: data)
    }

    private static func getPaywall(byPlacmentId id: String, profileId: String, from data: Data) throws -> AdaptyPaywallChosen? {
        let decoder = FallbackPaywalls.decoder(profileId: profileId, placmentId: id)

        struct Structure: Decodable {
            let chosen: AdaptyPaywallChosen?
            init(from decoder: any Decoder) throws {
                let placmentId = CustomCodingKeys(decoder.userInfo.placmentId ?? "")
                chosen = try decoder
                    .container(keyedBy: FallbackPaywalls.CodingKeys.self)
                    .nestedContainer(keyedBy: CustomCodingKeys.self, forKey: .data)
                    .decodeIfPresent(AdaptyPaywallChosen.self, forKey: placmentId)
            }
        }

        return try decoder.decode(Structure.self, from: data).chosen
    }
}

extension FallbackPaywalls: Decodable {
    enum CodingKeys: String, CodingKey {
        case data
        case meta
        case formatVersion = "version"
        case versionByPlacement = "placement_audience_version_updated_at_map"
    }

    init(from data: Data) throws {
        let decoder = JSONDecoder()
        Backend.configure(decoder: decoder)
        let obj = try decoder.decode(FallbackPaywalls.self, from: data)

        switch obj.source {
        case .unknown where !obj.versionByPlacement.isEmpty:
            self = .init(
                source: .data(data),
                formatVersion: obj.formatVersion,
                versionByPlacement: obj.versionByPlacement
            )
        default:
            self = obj
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let meta = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .meta)

        formatVersion = try meta.decode(Int.self, forKey: .formatVersion)

        guard formatVersion == FallbackPaywalls.currentFormatVersion else {
            source = .unknown
            versionByPlacement = [:]
            return
        }

        let versionsСontainer = try meta.nestedContainer(keyedBy: CustomCodingKeys.self, forKey: .versionByPlacement)

        versionByPlacement = try [String: Int64](
            versionsСontainer.allKeys.map {
                try ($0.stringValue, versionsСontainer.decode(Int64.self, forKey: $0))
            },
            uniquingKeysWith: { $1 }
        )

        guard let stringByPlacementId = try? container.decode([String: String].self, forKey: .data)
        else {
            source = .unknown
            return
        }

        source = .dataByPlacementId(stringByPlacementId.compactMapValues { $0.data(using: .utf8) })
    }
}

private extension [CodingUserInfoKey: Any] {
    var placmentId: String? {
        self[FallbackPaywalls.placmentIdUserInfoKey] as? String
    }
}

private extension FallbackPaywalls {
    static let placmentIdUserInfoKey = CodingUserInfoKey(rawValue: "adapty_placment_id")!

    static func decoder(profileId: String) -> JSONDecoder {
        let decoder = JSONDecoder()
        Backend.configure(decoder: decoder)
        decoder.setProfileId(profileId)
        return decoder
    }

    static func decoder(profileId: String, placmentId: String) -> JSONDecoder {
        let decoder = decoder(profileId: profileId)
        decoder.userInfo[FallbackPaywalls.placmentIdUserInfoKey] = placmentId
        return decoder
    }

    struct CustomCodingKeys: CodingKey {
        let stringValue: String
        let intValue: Int?
        init?(stringValue: String) {
            self.stringValue = stringValue
            intValue = nil
        }

        init(_ value: String) {
            stringValue = value
            intValue = nil
        }

        init?(intValue _: Int) {
            nil
        }
    }
}
