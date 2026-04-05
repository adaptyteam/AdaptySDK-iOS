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
    var formatVersion: Int {
        head.formatVersion
    }

    var version: Int64 {
        head.version
    }

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
        requestLocale: AdaptyLocale?
    ) -> AdaptyPlacementChosen<Content>? {
        guard contains(placementId: id) ?? true else { return nil }

        let draw: AdaptyPlacement.Draw<Content>?

        do {
            draw = try FallbackPlacements.decodeVariationFromData(
                Data(contentsOf: fileURL),
                withUserId: userId,
                withPlacementId: id,
                withVariationId: withVariationId,
                withRequestLocale: requestLocale,
                withFallbackVersion: version
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

    static func decodeVariationFromData<Content: PlacementContent>(
        _ data: Data,
        withUserId userId: AdaptyUserId,
        withPlacementId placementId: String,
        withVariationId variationId: String?,
        withRequestLocale requestLocale: AdaptyLocale?,
        withFallbackVersion fallbackVersion: Int64
    ) throws -> AdaptyPlacement.Draw<Content>? {
        let jsonDecoder = FallbackPlacements.decoder()

        if let jsonString = try? jsonDecoder.decode(
            Backend.Response.Data<String>.Placement.self,
            from: data,
            with: .init(placementId: placementId)
        ).value {
            let draw: AdaptyPlacement.Draw<Content> = try decodePlacementVariationFromData(
                jsonString.data(using: .utf8) ?? Data(),
                withUserId: userId,
                withVariationId: variationId,
                withRequestLocale: requestLocale,
                withFallbackVersion: fallbackVersion
            )
            return draw
        }

        guard let placement = try jsonDecoder
            .decode(
                Backend.Response.Data<AdaptyPlacement>.Placement.Meta.self,
                from: data,
                with: .init(placementId: placementId)
            )
            .value?.replace(version: fallbackVersion)
        else { return nil }

        return try jsonDecoder.decode(
            Backend.Response.Data<AdaptyPlacement.Draw<Content>>.Placement.Data.self,
            from: data,
            with: .init(
                userId: userId,
                placement: placement,
                requestLocale: requestLocale,
                variationId: variationId
            )
        ).value
    }

    private static func decodePlacementVariationFromData<Content: PlacementContent>(
        _ data: Data,
        withUserId userId: AdaptyUserId,
        withVariationId variationId: String?,
        withRequestLocale requestLocale: AdaptyLocale?,
        withFallbackVersion fallbackVersion: Int64
    ) throws -> AdaptyPlacement.Draw<Content> {
        let jsonDecoder = FallbackPlacements.decoder()

        let placement = try jsonDecoder.decode(
            Backend.Response.Meta<AdaptyPlacement>.self,
            from: data
        ).value.replace(version: fallbackVersion)

        return try jsonDecoder.decode(
            Backend.Response.Data<AdaptyPlacement.Draw<Content>>.self,
            from: data,
            with: .init(
                userId: userId,
                placement: placement,
                requestLocale: requestLocale,
                variationId: variationId
            )
        ).value
    }
}

private extension FallbackPlacements {
    static func decoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        Backend.configure(jsonDecoder: decoder)
        return decoder
    }

    struct DecodingConfiguration {
        let placementId: String
    }

    static func dataContainer(from decoder: Decoder) throws -> KeyedDecodingContainer<AnyCodingKeys> {
        try decoder
            .container(keyedBy: Backend.CodingKeys.self)
            .nestedContainer(keyedBy: AnyCodingKeys.self, forKey: .data)
    }

    static func placementContainer(from decoder: Decoder, placementId: String) throws -> KeyedDecodingContainer<Backend.CodingKeys>? {
        let data = try dataContainer(from: decoder)
        let placementId = AnyCodingKeys(stringValue: placementId)

        guard data.contains(placementId), try !data.decodeNil(forKey: placementId) else {
            return nil
        }

        return try data.nestedContainer(keyedBy: Backend.CodingKeys.self, forKey: placementId)
    }
}

private extension Backend.Response.Data {
    struct Placement: Sendable {
        let value: Value?
    }
}

extension Backend.Response.Data.Placement: DecodableWithConfiguration
    where Value: Decodable
{
    init(from decoder: Decoder, configuration: FallbackPlacements.DecodingConfiguration) throws
        where Value: Decodable
    {
        let container = try FallbackPlacements.dataContainer(from: decoder)
        let placementId = AnyCodingKeys(stringValue: configuration.placementId)
        value = try container.decodeIfPresent(Value.self, forKey: placementId)
    }
}

extension Backend.Response.Data.Placement {
    struct Meta: Sendable, DecodableWithConfiguration
        where Value: Decodable
    {
        let value: Value?

        init(from decoder: Decoder, configuration: FallbackPlacements.DecodingConfiguration) throws {
            let container = try FallbackPlacements.placementContainer(from: decoder, placementId: configuration.placementId)
            value = try container?.decode(Value.self, forKey: .meta)
        }
    }
}

extension Backend.Response.Data.Placement {
    struct Data: Sendable, DecodableWithConfiguration
        where Value: DecodableWithConfiguration, Value.DecodingConfiguration == AdaptyPlacement.DecodingConfiguration
    {
        let value: Value?

        init(from decoder: Decoder, configuration: AdaptyPlacement.DecodingConfiguration) throws {
            let container = try FallbackPlacements.placementContainer(from: decoder, placementId: configuration.placement.id)
            value = try container?.decode(Value.self, forKey: .data, configuration: configuration)
        }
    }
}

