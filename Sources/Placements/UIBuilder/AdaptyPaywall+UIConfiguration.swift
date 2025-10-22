//
//  AdaptyPaywall+UIBuilder.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.01.2023
//

import AdaptyUIBuilder
import Foundation

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
        guard let viewConfig = paywall.viewConfiguration else {
            throw .isNoViewConfigurationInPaywall()
        }

        let schema: AdaptyUISchema =
            if let value = try? viewConfig.schema {
                value
            } else if let value = restoreViewConfiguration(viewConfig.responseLocale, paywall) {
                value
            } else {
                try await fetchViewConfiguration(
                    paywallVariationId: paywall.variationId,
                    paywallInstanceIdentity: paywall.instanceIdentity,
                    locale: viewConfig.responseLocale,
                    loadTimeout: loadTimeout
                )
            }

        AdaptyUIBuilder.sendImageUrlsToObserver(schema, forLocalId: viewConfig.responseLocale.id)

        let extractLocaleTask = Task.detachedAsResultTask { () async throws(AdaptyError) -> AdaptyUIConfiguration in
            do {
                return try schema.extractUIConfiguration(
                    id: viewConfig.id,
                    withLocaleId: viewConfig.responseLocale.id
                )
            } catch {
                throw .decodingViewConfiguration(error)
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
            case let value = try? cachedViewConfiguration.schema
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
