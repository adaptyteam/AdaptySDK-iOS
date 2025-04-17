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
//    private let head: Head
    var formatVersion: Int { 8 } // head.formatVersion }
    var version: Int64 { 0 } // head.version }

    init(fileURL url: URL) throws {
//        guard url.isFileURL else {
//            throw AdaptyError.isNotFileUrl()
//        }
//        let decoder = FallbackPlacements.decoder()
//        do {
//            head = try decoder.decode(Head.self, from: Data(contentsOf: url))
//        } catch let error as AdaptyError {
//            throw error
//        } catch {
//            throw AdaptyError.decodingFallback(error)
//        }
        fileURL = url
    }

    func contains(placementId id: String) -> Bool? {
        return nil
//        head.placementIds?.contains(id)
    }

    func getPlacement<Content: AdaptyPlacementContent>(byPlacementId id: String, withVariationId: String?, profileId: String) -> AdaptyPlacementChosen<Content>? {
        return nil
//        guard contains(placementId: id) ?? true else { return nil }
//
//        let draw: AdaptyPlacement.Draw?
//
//        do {
//            let decoder = FallbackPlacements.decoder(profileId: profileId, placementId: id, paywallVariationId: withVariationId)
//            draw = try decoder.decode(Body.self, from: Data(contentsOf: fileURL)).draw?.replacedPaywallVersion(version)
//        } catch {
//            log.error(error.localizedDescription)
//            draw = nil
//        }
//
//        Log.crossAB.verbose("fallbackFile request: placementId = \(id), variationId = \(withVariationId ?? "nil DRAW") response: variationId = \(draw?.paywall.variationId ?? "nil")")
//
//        return draw.map { .draw($0) }
    }
}

// extension FallbackPlacements {
//    private enum CodingKeys: String, CodingKey {
////        case data
//        case meta
//        case formatVersion = "version"
//        case version = "response_created_at"
//        case placementIds = "developer_ids"
//    }
//
//    private struct Head: Sendable, Decodable {
//        let placementIds: Set<String>?
//        let version: Int64
//        let formatVersion: Int
//
//        init(from decoder: Decoder) throws {
//            let container = try decoder
//                .container(keyedBy: CodingKeys.self)
//                .nestedContainer(keyedBy: CodingKeys.self, forKey: .meta)
//
//            let formatVersion = try container.decode(Int.self, forKey: .formatVersion)
//
//            guard formatVersion == Adapty.fallbackFormatVersion else {
//                let error = formatVersion < Adapty.fallbackFormatVersion
//                    ? "The fallback paywalls version is not correct. Download a new one from the Adapty Dashboard."
//                    : "The fallback paywalls version is not correct. Please update the AdaptySDK."
//                log.error(error)
//
//                Task(priority: .high) {
//                    await Adapty.trackSystemEvent(AdaptyInternalEventParameters(eventName: "fallback_wrong_version", params: [
//                        "in_version": formatVersion,
//                        "expected_version": Adapty.fallbackFormatVersion,
//                    ]))
//                }
//
//                throw AdaptyError.wrongVersionFallback(error)
//            }
//
//            self.formatVersion = formatVersion
//            version = try container.decode(Int64.self, forKey: .version)
//            placementIds = try container.decodeIfPresent(Set<String>.self, forKey: .placementIds)
//        }
//    }
//
//    struct Body: Sendable, Decodable {
//        let draw: AdaptyPlacement.Draw?
//        init(from decoder: Decoder) throws {
//            let placementId = try AnyCodingKeys(stringValue: decoder.userInfo.placementId)
//            let container = try decoder
//                .container(keyedBy: CodingKeys.self)
//                .nestedContainer(keyedBy: AnyCodingKeys.self, forKey: .data)
//
//            guard container.contains(placementId) else {
//                draw = nil
//                return
//            }
//
//            if let string = try? container.decode(String.self, forKey: placementId) {
//                let data = string.data(using: .utf8) ?? Data()
//                let decoder = try FallbackPlacements.decoder(
//                    profileId: decoder.userInfo.profileId,
//                    paywallVariationId: decoder.userInfo.paywallVariationIdOrNil
//                )
//
//                draw = try decoder.decode(AdaptyPlacement.Draw.self, from: data)
//            } else {
//                draw = try container.decodeIfPresent(AdaptyPlacement.Draw.self, forKey: placementId)
//            }
//        }
//    }
// }
//
// private extension FallbackPlacements {
//    static func decoder() -> JSONDecoder {
//        let decoder = JSONDecoder()
//        Backend.configure(jsonDecoder: decoder)
//        return decoder
//    }
//
//    static func decoder(profileId: String, paywallVariationId: String?) -> JSONDecoder {
//        let decoder = decoder()
//        decoder.setProfileId(profileId)
//        if let paywallVariationId { decoder.setPaywallVariationId(paywallVariationId) }
//        return decoder
//    }
//
//    static func decoder(profileId: String, placementId: String, paywallVariationId: String?) -> JSONDecoder {
//        let decoder = decoder(profileId: profileId, paywallVariationId: paywallVariationId)
//        decoder.setPlacementId(placementId)
//        return decoder
//    }
// }
