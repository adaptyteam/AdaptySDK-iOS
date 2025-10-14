//
//  FallbackPlacements.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 30.09.2022.
//

import Foundation

private let log = Log.fallbackPlacements

struct FallbackPlacements: Sendable {
    private let fileURL: URL
    private let head: Head
    var formatVersion: Int { head.formatVersion }
    var version: Int64 { head.version }

    init(fileURL url: URL) throws(AdaptyError) {
        guard url.isFileURL else {
            throw .isNotFileUrl()
        }
        let decoder = FallbackPlacements.decoder()

        do {
            head = try decoder.decode(Head.self, from: Data(contentsOf: url))
        } catch {
            throw .decodingFallback(error)
        }
        fileURL = url
    }

    func contains(placementId id: String) -> Bool? {
        head.placementIds?.contains(id)
    }

    func getPlacement<Content: PlacementContent>(
        byPlacementId id: String,
        withVariationId: String?,
        userId: AdaptyUserId,
        requestLocale: AdaptyLocale
    ) -> AdaptyPlacementChosen<Content>? {
        guard contains(placementId: id) ?? true else { return nil }

        let draw: AdaptyPlacement.Draw<Content>?

        do {
            draw = try FallbackPlacements.decodePlacementVariation(
                Data(contentsOf: fileURL),
                withUserId: userId,
                withPlacementId: id,
                withVariationId: withVariationId,
                withRequestLocale: requestLocale,
                version: version
            )
        } catch {
            log.error(String(describing: error))
            draw = nil
        }

        Log.crossAB.verbose("fallbackFile request: placementId = \(id), variationId = \(withVariationId ?? "nil DRAW") response: variationId = \(draw?.content.variationId ?? "nil")")

        return draw.map { .draw($0) }
    }
}

private extension FallbackPlacements {
    struct Head: Sendable, Decodable {
        let placementIds: Set<String>?
        let version: Int64
        let formatVersion: Int

        enum CodingKeys: String, CodingKey {
            case formatVersion = "version"
            case version = "response_created_at"
            case placementIds = "developer_ids"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder
                .container(keyedBy: Backend.CodingKeys.self)
                .nestedContainer(keyedBy: CodingKeys.self, forKey: .meta)

            let formatVersion = try container.decode(Int.self, forKey: .formatVersion)

            guard formatVersion == Adapty.fallbackFormatVersion else {
                let error = Adapty.fallbackFormatVersion > formatVersion
                    ? "The fallback paywalls version is not correct. Download a new one from the Adapty Dashboard."
                    : "The fallback paywalls version is not correct. Please update the AdaptySDK."
                log.error(error)

                Adapty.trackSystemEvent(AdaptyInternalEventParameters(eventName: "fallback_wrong_version", params: [
                    "in_version": formatVersion,
                    "expected_version": Adapty.fallbackFormatVersion,
                ]))

                throw AdaptyError.wrongVersionFallback(error)
            }

            self.formatVersion = formatVersion
            version = try container.decode(Int64.self, forKey: .version)
            placementIds = try container.decodeIfPresent(Set<String>.self, forKey: .placementIds)
        }
    }

    static func decodePlacementVariation<Content: PlacementContent>(
        _ data: Data,
        withUserId userId: AdaptyUserId,
        withPlacementId placementId: String,
        withVariationId variationId: String?,
        withRequestLocale requestLocale: AdaptyLocale,
        version: Int64
    ) throws -> AdaptyPlacement.Draw<Content>? {
        let jsonDecoder = FallbackPlacements.decoder()
        jsonDecoder.userInfo.setPlacementId(placementId)
        jsonDecoder.userInfo.setUserId(userId)
        jsonDecoder.userInfo.setRequestLocale(requestLocale)

        if let variationId {
            jsonDecoder.userInfo.setPlacementVariationId(variationId)
        }

        if let string = try? jsonDecoder.decode(Backend.Response.Data<String>.Placement.self, from: data).value {
            let draw: AdaptyPlacement.Draw<Content> = try decodePlacementVariation(
                jsonDecoder,
                string.data(using: .utf8) ?? Data(),
                version: version
            )
            return draw
        }

        guard let placement = try jsonDecoder
            .decode(
                Backend.Response.Data<AdaptyPlacement>.Placement.Meta.self,
                from: data
            )
            .value?.replace(version: version)
        else { return nil }

        jsonDecoder.userInfo.setPlacement(placement)

        return try jsonDecoder.decode(
            Backend.Response.Data<AdaptyPlacement.Draw<Content>>.Placement.Data.self,
            from: data
        ).value
    }

    private static func decodePlacementVariation<Content: PlacementContent>(
        _ jsonDecoder: JSONDecoder,
        _ data: Data,
        version: Int64
    ) throws -> AdaptyPlacement.Draw<Content> {
        let placement = try jsonDecoder.decode(
            Backend.Response.Meta<AdaptyPlacement>.self,
            from: data
        ).value.replace(version: version)

        jsonDecoder.userInfo.setPlacement(placement)

        return try jsonDecoder.decode(
            Backend.Response.Data<AdaptyPlacement.Draw<Content>>.self,
            from: data
        ).value
    }
}

private extension FallbackPlacements {
    static func decoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        Backend.configure(jsonDecoder: decoder)
        return decoder
    }
}

private extension Backend.Response.Data {
    private static func data(from decoder: Decoder) throws -> KeyedDecodingContainer<AnyCodingKeys> {
        try decoder
            .container(keyedBy: Backend.CodingKeys.self)
            .nestedContainer(keyedBy: AnyCodingKeys.self, forKey: .data)
    }

    struct Placement: Sendable, Decodable where Value: Decodable, Value: Sendable {
        let value: Value?

        init(from decoder: Decoder) throws {
            value = try data(from: decoder)
                .decodeIfPresent(Value.self, forKey: AnyCodingKeys(stringValue: decoder.userInfo.placementId))
        }

        private static func placement(from decoder: Decoder) throws -> KeyedDecodingContainer<Backend.CodingKeys>? {
            let data = try data(from: decoder)
            let placementId = try AnyCodingKeys(stringValue: decoder.userInfo.placementId)

            guard data.contains(placementId), try !data.decodeNil(forKey: placementId) else {
                return nil
            }

            return try data.nestedContainer(keyedBy: Backend.CodingKeys.self, forKey: placementId)
        }

        struct Data: Sendable, Decodable {
            let value: Value?

            init(from decoder: Decoder) throws {
                value = try placement(from: decoder)?
                    .decode(Value.self, forKey: .data)
            }
        }

        struct Meta: Sendable, Decodable where Value: Decodable, Value: Sendable {
            let value: Value?

            init(from decoder: Decoder) throws {
                value = try placement(from: decoder)?
                    .decode(Value.self, forKey: .meta)
            }
        }
    }
}
