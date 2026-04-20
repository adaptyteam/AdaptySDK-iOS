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
        guard let viewConfigurationId = flow.viewConfigurationId else {
            throw .isNoViewConfigurationInFlow()
        }

        let schema = try await fetchUISchema(
            flowId: flow.id,
            viewConfigurationId: viewConfigurationId,
            loadTimeout: loadTimeout
        )

        AdaptyUIBuilder.sendImageUrlsToObserver(schema, forLocalId: locale.id)

        let envoriment = await Environment.fetchUIBuilderEnvironment()

        let extractLocaleTask = Task.detachedWithThrowsTyped(priority: .userInitiated) { () async throws(AdaptyError) -> AdaptyUIConfiguration in
            do {
                return try schema.extractUIConfiguration(
                    id: viewConfigurationId,
                    withLocaleId: locale.id,
                    envoriment: envoriment
                )
            } catch {
                throw .decodingViewConfiguration(error)
            }
        }

        return try await extractLocaleTask.valueWithThrowsTyped()
    }

    private func fetchUISchema(
        flowId: String,
        viewConfigurationId: String,
        loadTimeout: TaskDuration
    ) async throws(AdaptyError) -> AdaptyUISchema {
        if let schema = try? Adapty.fallbackPlacements?.getUISchema(byViewConfigurationId: viewConfigurationId) {
            return schema
        }

        let session = httpFallbackSession
        let apiKeyPrefix = apiKeyPrefix
        let isTestUser = profileManager?.isTestUser ?? false

        do {
            return try await withThrowingTimeout(loadTimeout - .milliseconds(500)) {
                try await session.fetchUISchema(
                    apiKeyPrefix: apiKeyPrefix,
                    flowId: flowId,
                    viewConfigurationId: viewConfigurationId,
                    disableServerCache: isTestUser
                )
            }
        } catch {
            if let httpError = error as? HTTPError, case .decoding = httpError {
                throw httpError.asAdaptyError
            }
        }

        do {
            return try await httpSession.fetchFallbackUISchema(
                apiKeyPrefix: apiKeyPrefix,
                flowId: flowId,
                viewConfigurationId: viewConfigurationId,
                disableServerCache: isTestUser
            )
        } catch {
            throw error.asAdaptyError
        }
    }
}

