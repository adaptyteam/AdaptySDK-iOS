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
    let version: Int

    func getPaywall(byPlacmentId id: String, profileId: String) -> AdaptyPaywall? {
        do {
            switch source {
            case let .dataByPlacementId(value):
                return try FallbackPaywalls.getPaywall(byPlacmentId: id, profileId: profileId, from: value)
            case let .data(value):
                return try FallbackPaywalls.getPaywall(byPlacmentId: id, profileId: profileId, from: value)
            case .unknown:
                return nil
            }
        } catch {
            Log.error(error.localizedDescription)
            return nil
        }
    }
}

private extension FallbackPaywalls {
    enum Source {
        case data(Data)
        case dataByPlacementId([String: Data])
        case unknown
    }

    private static func getPaywall(byPlacmentId id: String, profileId: String, from: [String: Data]) throws -> AdaptyPaywall? {
        guard let data = from[id] else { return nil }
        let decoder = FallbackPaywalls.decoder(profileId: profileId)
        let chosen = try decoder.decode(AdaptyPaywallChosen.self, from: data)
        return chosen.value
    }

    private static func getPaywall(byPlacmentId id: String, profileId: String, from data: Data) throws -> AdaptyPaywall? {
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
        let chosen = try decoder.decode(Structure.self, from: data).chosen
        return chosen?.value
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
        case .unknown:
            self = .init(source: .data(data), version: obj.version)
        default:
            self = obj
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var meta = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .meta)

        version = try meta.decode(Int.self, forKey: .formatVersion)

        guard version == FallbackPaywalls.currentFormatVersion else {
            source = .unknown
            return
        }
        
        

        guard
            let stringByPlacementId = try? container.decode([String: String].self, forKey: .data)
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
