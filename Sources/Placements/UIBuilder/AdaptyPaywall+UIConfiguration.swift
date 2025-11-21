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
    package nonisolated static func getUIConfiguration(
        paywall: AdaptyPaywall,
        loadTimeout: TimeInterval? = nil
    ) async throws -> AdaptyUIConfiguration {
        let loadTimeout = (loadTimeout ?? .defaultLoadPlacementTimeout).allowedLoadPlacementTimeout
        return try await activatedSDK.getUIConfiguration(
            paywall: paywall,
            loadTimeout: loadTimeout
        )
    }

    private func getUIConfiguration(
        paywall: AdaptyPaywall,
        loadTimeout: TaskDuration
    ) async throws(AdaptyError) -> AdaptyUIConfiguration {
        guard let viewConfiguration = paywall.viewConfiguration else {
            throw .isNoViewConfigurationInPaywall()
        }

        let schema: AdaptyUISchema =
            if let value = try? viewConfiguration.schema {
                value
            } else if let restored = restore(
                viewConfigurationLocale: viewConfiguration.locale,
                placementId: paywall.placement.id,
                paywallVariationId: paywall.variationId,
                paywallInstanceIdentity: paywall.instanceIdentity,
                placementRevision: paywall.placement.revision,
                placementVersion: paywall.placement.version
            ),
                let vc = restored.viewConfiguration,
                vc.locale == viewConfiguration.locale,
                let value = try? vc.schema
            {
                value
            } else {
                try await fetchUISchema(
                    paywallVariationId: paywall.variationId,
                    paywallInstanceIdentity: paywall.instanceIdentity,
                    locale: viewConfiguration.locale,
                    loadTimeout: loadTimeout
                )
            }

        AdaptyUIBuilder.sendImageUrlsToObserver(schema, forLocalId: viewConfiguration.locale.id)

        let extractLocaleTask = Task.detachedAsResultTask(priority: .userInitiated) { () async throws(AdaptyError) -> AdaptyUIConfiguration in
            do {
                return try schema.extractUIConfiguration(
                    id: viewConfiguration.id,
                    withLocaleId: viewConfiguration.locale.id
                )
            } catch {
                throw .decodingViewConfiguration(error)
            }
        }

        return try await extractLocaleTask.value.get()
    }

    private func restore(
        viewConfigurationLocale: AdaptyLocale,
        placementId: String,
        paywallVariationId: String,
        paywallInstanceIdentity: String,
        placementRevision: Int,
        placementVersion: Int64
    ) -> AdaptyPaywall? {
        if let cached: AdaptyPaywall = profileManager?.placementStorage.restorePaywall(
            placementId,
            withVariationId: paywallVariationId,
            withInstanceIdentity: paywallInstanceIdentity,
            withPlacementVersion: placementVersion,
            withPlacementRevision: placementRevision
        ) { return cached }

        if let fallbackFile = Adapty.fallbackPlacements,
           fallbackFile.version == placementVersion,
           let fallback: AdaptyPaywall = fallbackFile.restorePaywall(
               placementId,
               withVariationId: paywallVariationId,
               withInstanceIdentity: paywallInstanceIdentity,
               withPlacementRevision: placementRevision
           ) { return fallback }

        return nil
    }

    private func fetchUISchema(
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
                try await httpSession.fetchUISchema(
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
            return try await httpFallbackSession.fetchFallbackUISchema(
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
