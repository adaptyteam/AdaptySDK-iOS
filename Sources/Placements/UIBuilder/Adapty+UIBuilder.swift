//
//  Adapty+UIBuilder.swift
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
        device: DeviceInfo,
        customLayoutId: String?,
        locale: String?,
        loadTimeout: TimeInterval? = nil
    ) async throws -> (flowLayout: AdaptyFlow.Layout, configuration: AdaptyUIConfiguration) {
        let loadTimeout = (loadTimeout ?? .defaultLoadPlacementTimeout).allowedLoadPlacementTimeout
        return try await activatedSDK.getUIConfiguration(
            flow: flow,
            device: device,
            customLayoutId: customLayoutId,
            locale: locale.trimmed.nonEmptyOrNil.map { AdaptyLocale($0) } ?? .defaultPlacementLocale,
            loadTimeout: loadTimeout
        )
    }

    private func getUIConfiguration(
        flow: AdaptyFlow,
        device: DeviceInfo,
        customLayoutId: String?,
        locale: AdaptyLocale,
        loadTimeout: TaskDuration
    ) async throws(AdaptyError) -> (flowLayout: AdaptyFlow.Layout, configuration: AdaptyUIConfiguration) {
        guard
            let layoutsConfiguration = flow.layoutsConfiguration,
            let layout = try layoutsConfiguration.getLayout(for: device, with: customLayoutId)
        else {  throw .isNoViewConfigurationInFlow() }

        let schema = try await getUISchema(
            flowId: flow.id,
            flowLayout: layout,
            loadTimeout: loadTimeout,
            decodingConfiguration: .init(device: device.kind)
        )

        AdaptyUIBuilder.sendImageUrlsToObserver(schema, forLocalId: locale.id)

        let envoriment = await Environment.fetchUIBuilderEnvironment(flow: flow)

        let extractLocaleTask = Task.detachedWithThrowsTyped(priority: .userInitiated) { () async throws(AdaptyError) -> AdaptyUIConfiguration in
            do {
                return try schema.extractUIConfiguration(
                    id: layout.id,
                    withLocaleId: locale.id,
                    envoriment: envoriment
                )
            } catch {
                throw .extractAdaptyUIConfiguration(error)
            }
        }

        let configuration = try await extractLocaleTask.valueWithThrowsTyped()
        return (layout, configuration)
    }

    private func getUISchema(
        flowId: String,
        flowLayout: AdaptyFlow.Layout,
        loadTimeout: TaskDuration,
        decodingConfiguration: AdaptyUISchema.DecodingConfiguration
    ) async throws(AdaptyError) -> AdaptyUISchema {
        let isTestUser = profileManager?.isTestUser ?? false
        let cacheKey = flowLayout.cacheKey

        if !isTestUser, let schema = await fetchLocalUISchema(cacheKey, decodingConfiguration: decodingConfiguration) {
            return schema
        }

        let schema: AdaptyUISchema
        let data: Data

        do {
            (schema, data) = try await fetchBackendUISchema(
                flowId: flowId,
                flowLayout: flowLayout,
                loadTimeout: loadTimeout,
                disableServerCache: isTestUser,
                decodingConfiguration: decodingConfiguration
            )
            log.verbose("UI schema source = backend (\(flowLayout.id))")
        } catch {
            if isTestUser, let schema = await fetchLocalUISchema(cacheKey, decodingConfiguration: decodingConfiguration) {
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
                )
            } catch {
                Log.cache.error("Failed to write schema to cache: \(error)")
            }
        }

        return schema
    }

    private func fetchLocalUISchema(
        _ key: Cache.ItemKey,
        decodingConfiguration: AdaptyUISchema.DecodingConfiguration
    ) async -> AdaptyUISchema? {
        if let schema = await Cache.read(
            key,
            decode: { _, data in
                try AdaptyUISchema(from: data, configuration: decodingConfiguration)
            }
        ) {
            log.verbose("UI schema source = disk cache (\(key.itemId))")
            return schema
        }

        if let schema = try? Adapty.fallbackPlacements?.getUISchema(
            byFlowLayoutId: key.itemId,
            decodingConfiguration: decodingConfiguration
        ) {
            log.verbose("UI schema source = packed fallback (\(key.itemId))")
            return schema
        }

        return nil
    }

    private func fetchBackendUISchema(
        flowId: String,
        flowLayout: AdaptyFlow.Layout,
        loadTimeout: TaskDuration,
        disableServerCache: Bool,
        decodingConfiguration: AdaptyUISchema.DecodingConfiguration
    ) async throws(AdaptyError) -> (schema: AdaptyUISchema, data: Data) {
        let session = httpFallbackSession
        let apiKeyPrefix = apiKeyPrefix

        do {
            return try await withThrowingTimeout(max(loadTimeout - .milliseconds(500), .milliseconds(500))) {
                try await session.fetchUISchema(
                    apiKeyPrefix: apiKeyPrefix,
                    flowId: flowId,
                    flowLayout: flowLayout,
                    disableServerCache: disableServerCache,
                    decodingConfiguration: decodingConfiguration
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
                flowLayout: flowLayout,
                disableServerCache: disableServerCache,
                decodingConfiguration: decodingConfiguration
            )
        } catch {
            throw error.asAdaptyError
        }
    }
}

