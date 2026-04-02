//
//  AdaptyFlow+UIBuilder.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.01.2023
//

import AdaptyUIBuilder
import Foundation

@AdaptyActor
extension Adapty {
    package nonisolated static func getUIConfiguration(
        flow: AdaptyFlow,
        locale: String?,
        loadTimeout: TimeInterval? = nil
    ) async throws -> AdaptyUIConfiguration {
        let loadTimeout = (loadTimeout ?? .defaultLoadPlacementTimeout).allowedLoadPlacementTimeout
        return try await activatedSDK.getUIConfiguration(
            flow: flow,
            locale: locale.trimmed.nonEmptyOrNil.map { AdaptyLocale($0) } ?? .defaultPlacementLocale,
            loadTimeout: loadTimeout
        )
    }

    private func getUIConfiguration(
        flow: AdaptyFlow,
        locale: AdaptyLocale,
        loadTimeout: TaskDuration
    ) async throws(AdaptyError) -> AdaptyUIConfiguration {
        guard let viewConfiguration = flow.viewConfiguration else {
            throw .isNoViewConfigurationInFlow()
        }

        let schema: AdaptyUISchema =
            if let value = try? viewConfiguration.schema {
                value
//            } else if let restored = restore(
//                viewConfigurationLocale: viewConfiguration.locale,
//                placementId: paywall.placement.id,
//                paywallVariationId: paywall.variationId,
//                paywallInstanceIdentity: paywall.instanceIdentity,
//                placementRevision: paywall.placement.revision,
//                placementVersion: paywall.placement.version
//            ),
//                let vc = restored.viewConfiguration,
//                vc.locale == viewConfiguration.locale,
//                let value = try? vc.schema
//            {
//                value
            } else {
                try await fetchUISchema(
                    flowVariationId: flow.variationId,
                    flowInstanceIdentity: flow.instanceIdentity,
                    loadTimeout: loadTimeout
                )
            }

        AdaptyUIBuilder.sendImageUrlsToObserver(schema, forLocalId: locale.id)

        let extractLocaleTask = Task.detachedWithThrowsTyped(priority: .userInitiated) { () async throws(AdaptyError) -> AdaptyUIConfiguration in
            do {
                return try schema.extractUIConfiguration(
                    id: viewConfiguration.id,
                    withLocaleId: locale.id
                )
            } catch {
                throw .decodingViewConfiguration(error)
            }
        }

        return try await extractLocaleTask.valueWithThrowsTyped()
    }

//    private func restore(
//        viewConfigurationLocale _: AdaptyLocale,
//        placementId: String,
//        variationId: String,
//        instanceIdentity: String,
//        placementRevision: Int,
//        placementVersion: Int64
//    ) -> AdaptyFlow? {
//        if let cached: AdaptyFlow = profileManager?.placementStorage.restoreFlow(
//            placementId,
//            withVariationId: variationId,
//            withInstanceIdentity: instanceIdentity,
//            withPlacementVersion: placementVersion,
//            withPlacementRevision: placementRevision
//        ) { return cached }
//
//        if let fallbackFile = Adapty.fallbackPlacements,
//           fallbackFile.version == placementVersion,
//           let fallback: AdaptyFlow = fallbackFile.restoreFlow(
//               placementId,
//               withVariationId: variationId,
//               withInstanceIdentity: instanceIdentity,
//               withPlacementRevision: placementRevision
//           ) { return fallback }
//
//        return nil
//    }



    private func fetchUISchema(
        flowVariationId: String,
        flowInstanceIdentity: String,
        loadTimeout: TaskDuration
    ) async throws(AdaptyError) -> AdaptyUISchema {
        let httpSession = httpSession
        let apiKeyPrefix = apiKeyPrefix
        let isTestUser = profileManager?.isTestUser ?? false

        do {
            return try await withThrowingTimeout(loadTimeout - .milliseconds(500)) {
                try await httpSession.fetchUISchema(
                    apiKeyPrefix: apiKeyPrefix,
                    flowVariationId: flowVariationId,
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
                flowInstanceIdentity: flowInstanceIdentity,
                disableServerCache: isTestUser
            )
        } catch {
            throw error.asAdaptyError
        }
    }
}

