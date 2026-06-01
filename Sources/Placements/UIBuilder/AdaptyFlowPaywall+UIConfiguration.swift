//
//  AdaptyFlow+UIBuilder.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.01.2023
//

import AdaptyUIBuilder
import Foundation

private let log = Log.default

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

        let schema = try await getUISchema(
            flowId: flow.id,
            viewConfigurationId: viewConfigurationId,
            loadTimeout: loadTimeout
        )

        AdaptyUIBuilder.sendImageUrlsToObserver(schema, forLocalId: locale.id)

        let envoriment = await Environment.fetchUIBuilderEnvironment(flow: flow)

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

    private func getUISchema(
        flowId: String,
        viewConfigurationId: String,
        loadTimeout: TaskDuration
    ) async throws(AdaptyError) -> AdaptyUISchema {
        let isTestUser = profileManager?.isTestUser ?? false
        let cacheKey = Cache.ItemKey(profileId: nil, itemType: .uischema, itemId: viewConfigurationId)

        if !isTestUser, let schema = await fetchLocalUISchema(cacheKey) {
            return schema
        }

        let schema: AdaptyUISchema
        let data: Data

        do {
            (schema, data) = try await fetchBackendUISchema(
                flowId: flowId,
                viewConfigurationId: viewConfigurationId,
                loadTimeout: loadTimeout,
                disableServerCache: isTestUser
            )
            log.verbose("UI schema source = backend (\(viewConfigurationId))")
        } catch {
            if isTestUser, let schema = await fetchLocalUISchema(cacheKey) {
                return schema
            }
            throw error
        }

        Task.detached {
            do {
                try await Cache.write(
                    data,
                    key: cacheKey,
                    dataVersion: 0,
                    accept: { _, _ in true }
                )
            } catch {
                Log.cache.error("Failed to write schema to cache: \(error)")
            }
        }

        return schema
    }

    private func fetchLocalUISchema(_ key: Cache.ItemKey) async -> AdaptyUISchema? {
        if let schema = await Cache.read(
            key,
            accept: { _ in true },
            decode: AdaptyUISchema.init
        ) {
            log.verbose("UI schema source = disk cache (\(key.itemId))")
            return schema
        }

        if let schema = try? Adapty.fallbackPlacements?.getUISchema(byViewConfigurationId: key.itemId) {
            log.verbose("UI schema source = packed fallback (\(key.itemId))")
            return schema
        }

        return nil
    }

    private func fetchBackendUISchema(
        flowId: String,
        viewConfigurationId: String,
        loadTimeout: TaskDuration,
        disableServerCache: Bool
    ) async throws(AdaptyError) -> (schema: AdaptyUISchema, data: Data) {
        let session = httpFallbackSession
        let apiKeyPrefix = apiKeyPrefix

        do {
            return try await withThrowingTimeout(loadTimeout - .milliseconds(500)) {
                try await session.fetchUISchema(
                    apiKeyPrefix: apiKeyPrefix,
                    flowId: flowId,
                    viewConfigurationId: viewConfigurationId,
                    disableServerCache: disableServerCache
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
                disableServerCache: disableServerCache
            )
        } catch {
            throw error.asAdaptyError
        }
    }
}
