//
//  Adapty+AdaptyUIConfiguration.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.01.2023
//

import Foundation
import AdaptyUIBuider

@AdaptyActor
extension Adapty {
    package nonisolated static func getViewConfiguration(
        paywall: AdaptyPaywall,
        loadTimeout: TimeInterval? = nil
    ) async throws -> AdaptyUIConfiguration {
        let loadTimeout = (loadTimeout ?? .defaultLoadPlacementTimeout).allowedLoadPlacementTimeout
        return try await activatedSDK.getViewConfiguration(
            paywall: paywall,
            loadTimeout: loadTimeout
        )
    }

    private func getViewConfiguration(
        paywall: AdaptyPaywall,
        loadTimeout: TaskDuration
    ) async throws(AdaptyError) -> AdaptyUIConfiguration {
        guard let container = paywall.viewConfiguration else {
            throw .isNoViewConfigurationInPaywall()
        }

        let viewConfiguration: AdaptyUISchema =
            switch container {
            case let .value(value): value
            case let .json(locale, _, json):
                if let value = try? json.map(AdaptyUISchema.init) {
                    value
                } else if let value = restoreViewConfiguration(locale, paywall) {
                    value
                } else {
                    try await fetchViewConfiguration(
                        paywallVariationId: paywall.variationId,
                        paywallInstanceIdentity: paywall.instanceIdentity,
                        locale: locale,
                        loadTimeout: loadTimeout
                    )
                }
            }

        Adapty.sendImageUrlsToObserver(viewConfiguration)

        let extractLocaleTask: AdaptyResultTask<AdaptyUIConfiguration> = Task {
            do {
                return try .success(viewConfiguration.extractLocale())
            } catch {
                return .failure(.decodingViewConfiguration(error))
            }
        }

        return try await extractLocaleTask.value.get()
    }

    private func restoreViewConfiguration(_ locale: AdaptyLocale, _ paywall: AdaptyPaywall) -> AdaptyUISchema? {
        guard
            let cached: AdaptyPaywall = profileManager?.placementStorage.getPlacementByLocale(locale, orDefaultLocale: false, withPlacementId: paywall.placement.id, withVariationId: paywall.variationId)?.value,
            paywall.instanceIdentity == cached.instanceIdentity,
            paywall.placement.revision == cached.placement.revision,
            paywall.placement.version == cached.placement.version,
            let cachedViewConfiguration = cached.viewConfiguration,
            case let .value(value) = cachedViewConfiguration
        else { return nil }

        return value
    }

    private func fetchViewConfiguration(
        paywallVariationId: String,
        paywallInstanceIdentity: String,
        locale: AdaptyLocale,
        loadTimeout: TaskDuration
    ) async throws(AdaptyError) -> AdaptyUISchema {
        let httpSession = httpSession
        let apiKeyPrefix = apiKeyPrefix
        let isTestUser = profileManager?.isTestUser ?? false

        do {
            return try await withThrowingTimeout(loadTimeout - .milliseconds(500)) {
                try await httpSession.fetchViewConfiguration(
                    apiKeyPrefix: apiKeyPrefix,
                    paywallVariationId: paywallVariationId,
                    locale: locale,
                    disableServerCache: isTestUser
                )
            }
        } catch let error as HTTPError {
            guard Backend.canUseFallbackServer(error) else {
                throw error.asAdaptyError
            }
        } catch {
            guard error is TimeoutError else {
                throw .unknown(error)
            }
        }

        do {
            return try await httpFallbackSession.fetchFallbackViewConfiguration(
                apiKeyPrefix: apiKeyPrefix,
                paywallInstanceIdentity: paywallInstanceIdentity,
                locale: locale,
                disableServerCache: isTestUser
            )
        } catch {
            throw error.asAdaptyError
        }
    }
}
