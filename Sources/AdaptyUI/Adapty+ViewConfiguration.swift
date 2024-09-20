//
//  Adapty+getViewConfiguration.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.01.2023
//

import Foundation

extension Adapty {
    package static func getViewConfiguration(
        paywall: AdaptyPaywall,
        loadTimeout: TimeInterval = .defaultLoadPaywallTimeout
    ) async throws -> AdaptyUI.LocalizedViewConfiguration {
        try await withActivatedSDK { sdk in
            try await sdk.getViewConfiguration(paywall: paywall, loadTimeout: loadTimeout)
        }
    }

    private func getViewConfiguration(
        paywall: AdaptyPaywall,
        loadTimeout: TimeInterval
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

        do {
            return try viewConfiguration.extractLocale()
        } catch {
            throw AdaptyError.decodingViewConfiguration(error)
        }
    }

    private func restoreViewConfiguration(_: AdaptyLocale, _: AdaptyPaywall) -> AdaptyUI.ViewConfiguration? {
        nil
        // TODO: impliment
//        guard
//            let manager = state.initialized, manager.isActive,
//            let cached = manager.paywallsCache.getPaywallByLocale(locale, orDefaultLocale: false, withPlacementId: paywall.placementId)?.value,
//            paywall.variationId == cached.variationId,
//            paywall.instanceIdentity == cached.instanceIdentity,
//            paywall.revision == cached.revision,
//            paywall.version == cached.version,
//            let cachedViewConfiguration = cached.viewConfiguration,
//            case let .data(data) = cachedViewConfiguration
//        else { return nil }
//
//        return data
    }

    private func fetchViewConfiguration(
        paywallVariationId: String,
        paywallInstanceIdentity: String,
        locale: AdaptyLocale,
        loadTimeout: TimeInterval
    ) async throws -> AdaptyUI.ViewConfiguration {
        let httpSession = self.httpSession
        let apiKeyPrefix = self.apiKeyPrefix
        let isTestUser = self.profileStorage.getProfile()?.value.isTestUser ?? false

        do {
            return try await withThrowingTimeout(seconds: loadTimeout - 0.5) {
                try await httpSession.performFetchViewConfigurationRequest(
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
            return try await httpFallbackSession.performFetchFallbackViewConfigurationRequest(
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
