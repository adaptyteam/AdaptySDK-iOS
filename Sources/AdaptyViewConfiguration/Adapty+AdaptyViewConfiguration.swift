//
//  Adapty+AdaptyViewConfiguration.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.01.2023
//

import Foundation

@AdaptyActor
extension Adapty {
    package nonisolated static func getViewConfiguration(
        paywall: AdaptyPaywall,
        loadTimeout: TimeInterval? = nil
    ) async throws -> AdaptyViewConfiguration {
        let loadTimeout = (loadTimeout ?? .defaultLoadPlacementTimeout).allowedLoadPlacementTimeout
        return try await activatedSDK.getViewConfiguration(
            paywall: paywall,
            loadTimeout: loadTimeout
        )
    }

    private func getViewConfiguration(
        paywall: AdaptyPaywall,
        loadTimeout: TaskDuration
    ) async throws -> AdaptyViewConfiguration {
        guard let container = paywall.viewConfiguration else {
            throw AdaptyError.isNoViewConfigurationInPaywall()
        }

        let viewConfiguration: AdaptyViewSource =
            switch container {
            case let .value(value): value
            case let .json(locale, _, json):
                if let value = try? json.map(AdaptyViewSource.init) {
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

        let extractLocaleTask = Task {
            do {
                return try viewConfiguration.extractLocale()
            } catch {
                throw AdaptyError.decodingViewConfiguration(error)
            }
        }

        return try await extractLocaleTask.value
    }

    private func restoreViewConfiguration(_ locale: AdaptyLocale, _ paywall: AdaptyPaywall) -> AdaptyViewSource? {
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
    ) async throws -> AdaptyViewSource {
        let httpSession = httpSession
        let apiKeyPrefix = apiKeyPrefix
        let isTestUser = profileManager?.profile.value.isTestUser ?? false

        do {
            return try await withThrowingTimeout(loadTimeout - .milliseconds(500)) {
                try await httpSession.fetchViewConfiguration(
                    apiKeyPrefix: apiKeyPrefix,
                    paywallVariationId: paywallVariationId,
                    locale: locale,
                    disableServerCache: isTestUser
                )
            }
        } catch is TimeoutError {
        } catch let error as HTTPError {
            guard Backend.canUseFallbackServer(error) else {
                throw error.asAdaptyError
            }
        } catch {
            throw error.asAdaptyError ?? .fetchViewConfigurationFailed(unknownError: error)
        }

        do {
            return try await httpFallbackSession.fetchFallbackViewConfiguration(
                apiKeyPrefix: apiKeyPrefix,
                paywallInstanceIdentity: paywallInstanceIdentity,
                locale: locale,
                disableServerCache: isTestUser
            )
        } catch {
            throw error.asAdaptyError ?? .fetchViewConfigurationFailed(unknownError: error)
        }
    }
}
