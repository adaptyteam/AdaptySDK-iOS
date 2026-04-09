//
//  FallbackPlacements.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 30.09.2022.
//

import AdaptyCodable
import AdaptyUIBuilder
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
            let data = try Data(contentsOf: url).jsonExtract(pointer: "/meta")
            head = try decoder.decode(Head.self, from: data)
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
        withVariationId variationId: String?,
        userId: AdaptyUserId,
        requestLocale: AdaptyLocale?
    ) throws -> AdaptyPlacementChosen<Content>? {
        let draw: AdaptyPlacement.Draw<Content>

        do {
            guard let data = try Data(contentsOf: fileURL).jsonExtractIfPresent(pointer: "/data/\(id)") else {
                Log.crossAB.verbose("fallbackFile request: placementId = \(id), variationId = \(variationId ?? "nil DRAW") response: nil")

                return nil
            }
            draw = try FallbackPlacements.decodePlacementVariationFromData(
                data,
                withUserId: userId,
                withVariationId: variationId,
                withRequestLocale: requestLocale,
                withFallbackVersion: version
            )
        } catch {
            log.error(String(describing: error))
            Log.crossAB.verbose("fallbackFile request: placementId = \(id), variationId = \(variationId ?? "nil DRAW") error: \(error)")
            throw error
        }

        Log.crossAB.verbose("fallbackFile request: placementId = \(id), variationId = \(variationId ?? "nil DRAW") response: variationId = \(draw.content.variationId)")

        return .draw(draw)
    }

    func getUISchema(
        byViewConfigurationId id: String
    ) throws -> AdaptyUISchema? {
        let schema: AdaptyUISchema?
        do {
            let file = try Data(contentsOf: fileURL)
            guard let data = try file.jsonExtractIfPresent(pointer: "/ui_builder/\(id)") else {
                return nil
            }
            schema = try AdaptyUISchema(from: data)
        } catch {
            log.error(String(describing: error))
            throw error
        }
        return schema
    }
}

private extension FallbackPlacements {
    static func decoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        Backend.configure(jsonDecoder: decoder)
        return decoder
    }

    struct Head: Sendable, Decodable {
        var placementIds: Set<String>?
        let version: Int64
        let formatVersion: Int

        enum CodingKeys: String, CodingKey {
            case formatVersion = "version"
            case version = "response_created_at"
            case placementIds = "developer_ids"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            let formatVersion = try container.decode(Int.self, forKey: .formatVersion)

            print(formatVersion)

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

