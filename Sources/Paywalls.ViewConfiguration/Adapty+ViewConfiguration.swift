//
//  Adapty+getViewConfiguration.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.01.2023
//

import Foundation

@AdaptyActor
extension Adapty {
    package nonisolated static func getViewConfiguration(
        paywall: AdaptyPaywall,
        loadTimeout: TimeInterval = .defaultLoadPaywallTimeout
    ) async throws -> AdaptyUI.LocalizedViewConfiguration {
        let loadTimeout = loadTimeout.allowedLoadPaywallTimeout
        return try await activatedSDK.getViewConfiguration(
            paywall: paywall,
            loadTimeout: loadTimeout
        )
    }

    private func getViewConfiguration(
        paywall: AdaptyPaywall,
        loadTimeout: TaskDuration
    ) async throws -> AdaptyUI.LocalizedViewConfiguration {
        guard let container = paywall.viewConfiguration else {
            throw AdaptyError.isNoViewConfigurationInPaywall()
        }

        let viewConfiguration: AdaptyUI.ViewConfiguration =
            switch container {
            case let .data(value):
                value
            case let .withoutData(locale, _):
                if let value = restoreViewConfiguration(locale, paywall) {
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

        AdaptyUI.sendImageUrlsToObserver(viewConfiguration)

        let extractLocaleTask = Task {
            do {
                return try viewConfiguration.extractLocale()
            } catch {
                throw AdaptyError.decodingViewConfiguration(error)
            }
        }

        return try await extractLocaleTask.value
    }

    private func restoreViewConfiguration(_ locale: AdaptyLocale, _ paywall: AdaptyPaywall) -> AdaptyUI.ViewConfiguration? {
        guard
            let cached = profileManager?.paywallsStorage.getPaywallByLocale(locale, orDefaultLocale: false, withPlacementId: paywall.placementId)?.value,
            paywall.variationId == cached.variationId,
            paywall.instanceIdentity == cached.instanceIdentity,
            paywall.revision == cached.revision,
            paywall.version == cached.version,
            let cachedViewConfiguration = cached.viewConfiguration,
            case let .data(data) = cachedViewConfiguration
        else { return nil }

        return data
    }

    private func fetchViewConfiguration(
        paywallVariationId: String,
        paywallInstanceIdentity: String,
        locale: AdaptyLocale,
        loadTimeout: TaskDuration
    ) async throws -> AdaptyUI.ViewConfiguration {
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
