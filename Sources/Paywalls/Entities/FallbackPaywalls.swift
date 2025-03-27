//
//  FallbackPaywalls.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 30.09.2022.
//

import Foundation

private let log = Log.fallbackPaywalls

struct FallbackPaywalls: Sendable {
    private let fileURL: URL
    private let head: Head
    var formatVersion: Int { head.formatVersion }
    var version: Int64 { head.version }

    init(fileURL url: URL) throws {
        guard url.isFileURL else {
            throw AdaptyError.isNotFileUrl()
        }
        let decoder = FallbackPaywalls.decoder()
        do {
            head = try decoder.decode(Head.self, from: Data(contentsOf: url))
        } catch let error as AdaptyError {
            throw error
        } catch {
            throw AdaptyError.decodingFallback(error)
        }
        fileURL = url
    }

    func contains(placementId id: String) -> Bool? {
        head.placementIds?.contains(id)
    }

    func getPaywall(byPlacementId id: String, withVariationId: String?, profileId: String) -> AdaptyPaywallChosen? {
        guard contains(placementId: id) ?? true else { return nil }

        let paywall: AdaptyPaywall?
        do {
            if let variationId = withVariationId {
                let decoder = FallbackPaywalls.decoder(placementId: id, paywallVariationId: variationId)
                paywall = try decoder.decode(FallbackPaywalls.Value.self, from: Data(contentsOf: fileURL)).paywall
            } else {
                let decoder = FallbackPaywalls.decoder(profileId: profileId, placementId: id)
                paywall = try decoder.decode(FallbackPaywalls.Draw.self, from: Data(contentsOf: fileURL)).paywall
            }
        } catch {
            log.error(error.localizedDescription)
            paywall = nil
        }

        Log.crossAB.verbose("fallbackFile request: placementId = \(id), variationId = \(withVariationId ?? "nil DRAW") response: variationId = \(paywall == nil ? "nil" : (paywall?.variationId ?? ""))")

        return paywall.map {
            var v = $0
            v.version = version
            return .draw(v, profileId: profileId)
        }
    }
}

extension FallbackPaywalls {
    private enum CodingKeys: String, CodingKey {
        case data
        case meta
        case formatVersion = "version"
        case version = "response_created_at"
        case placementIds = "developer_ids"
    }

    private struct Head: Sendable, Decodable {
        let placementIds: Set<String>?
        let version: Int64
        let formatVersion: Int

        init(from decoder: Decoder) throws {
            let container = try decoder
                .container(keyedBy: CodingKeys.self)
                .nestedContainer(keyedBy: CodingKeys.self, forKey: .meta)

            let formatVersion = try container.decode(Int.self, forKey: .formatVersion)

            guard formatVersion == Adapty.fallbackFormatVersion else {
                let error = formatVersion < Adapty.fallbackFormatVersion
                    ? "The fallback paywalls version is not correct. Download a new one from the Adapty Dashboard."
                    : "The fallback paywalls version is not correct. Please update the AdaptySDK."
                log.error(error)

                Task(priority: .high) {
                    await Adapty.trackSystemEvent(AdaptyInternalEventParameters(eventName: "fallback_wrong_version", params: [
                        "in_version": formatVersion,
                        "expected_version": Adapty.fallbackFormatVersion,
                    ]))
                }

                throw AdaptyError.wrongVersionFallback(error)
            }

            self.formatVersion = formatVersion
            version = try container.decode(Int64.self, forKey: .version)
            placementIds = try container.decodeIfPresent(Set<String>.self, forKey: .placementIds)
        }
    }

    struct Draw: Sendable, Decodable {
        let paywall: AdaptyPaywall?
        init(from decoder: Decoder) throws {
            let placementId = try AnyCodingKeys(stringValue: decoder.userInfo.placementId)
            let container = try decoder
                .container(keyedBy: CodingKeys.self)
                .nestedContainer(keyedBy: AnyCodingKeys.self, forKey: .data)

            guard container.contains(placementId) else {
                paywall = nil
                return
            }

            if let string = try? container.decode(String.self, forKey: placementId) {
                let data = string.data(using: .utf8) ?? Data()
                let decoder = try FallbackPaywalls.decoder(profileId: decoder.userInfo.profileId)

                paywall = try decoder.decode(AdaptyPaywallVariations.Draw.self, from: data).paywall
            } else {
                paywall = try container.decodeIfPresent(AdaptyPaywallVariations.Draw.self, forKey: placementId)?.paywall
            }
        }
    }

    struct Value: Sendable, Decodable {
        let paywall: AdaptyPaywall?
        init(from decoder: Decoder) throws {
            let placementId = try AnyCodingKeys(stringValue: decoder.userInfo.placementId)
            let container = try decoder
                .container(keyedBy: CodingKeys.self)
                .nestedContainer(keyedBy: AnyCodingKeys.self, forKey: .data)

            guard container.contains(placementId) else {
                paywall = nil
                return
            }

            if let string = try? container.decode(String.self, forKey: placementId) {
                let data = string.data(using: .utf8) ?? Data()
                let decoder = try FallbackPaywalls.decoder(paywallVariationId: decoder.userInfo.paywallVariationId)

                paywall = try decoder.decode(AdaptyPaywallVariations.Value.self, from: data).paywall
            } else {
                paywall = try container.decodeIfPresent(AdaptyPaywallVariations.Value.self, forKey: placementId)?.paywall
            }
        }
    }
}

private extension FallbackPaywalls {
    static func decoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        Backend.configure(jsonDecoder: decoder)
        return decoder
    }

    static func decoder(profileId: String) -> JSONDecoder {
        let decoder = decoder()
        decoder.setProfileId(profileId)
        return decoder
    }

    static func decoder(paywallVariationId: String) -> JSONDecoder {
        let decoder = decoder()
        decoder.setPaywallVariationId(paywallVariationId)
        return decoder
    }

    static func decoder(profileId: String, placementId: String) -> JSONDecoder {
        let decoder = decoder(profileId: profileId)
        decoder.setPlacementId(placementId)
        return decoder
    }

    static func decoder(placementId: String, paywallVariationId: String) -> JSONDecoder {
        let decoder = decoder(paywallVariationId: paywallVariationId)
        decoder.setPlacementId(placementId)
        return decoder
    }
}
