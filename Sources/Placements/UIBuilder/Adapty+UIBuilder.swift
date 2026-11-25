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
        preferredLocales: [String],
        localizationStrategy: AdaptyUILocalizationStrategy,
        loadTimeout: TimeInterval? = nil
    ) async throws -> (flowLayoutVariant: AdaptyFlow.LayoutVariant, configuration: AdaptyUIConfiguration) {
        let loadTimeout = (loadTimeout.map(AdaptyDuration.seconds) ?? .defaultLoadPlacementTimeout).allowedLoadPlacementTimeout
        return try await activatedSDK.getUIConfiguration(
            flow: flow,
            device: device,
            customLayoutId: customLayoutId,
            preferredLocales: preferredLocales.compactMap(\.trimmed.nonEmptyOrNil),
            localizationStrategy: localizationStrategy,
            loadTimeout: loadTimeout
        )
    }

    private func getUIConfiguration(
        flow: AdaptyFlow,
        device: DeviceInfo,
        customLayoutId: String?,
        preferredLocales: [String],
        localizationStrategy: AdaptyUILocalizationStrategy,
        loadTimeout: AdaptyDuration
    ) async throws(AdaptyError) -> (flowLayoutVariant: AdaptyFlow.LayoutVariant, configuration: AdaptyUIConfiguration) {
        guard
            let layoutsConfiguration = flow.layoutsConfiguration,
            let layout = try layoutsConfiguration.getLayout(for: device, with: customLayoutId)
        else { throw .isNoViewConfigurationInFlow() }

        let layoutVariant = AdaptyFlow.LayoutVariant(
            versionId: layoutsConfiguration.versionId,
            id: layout.id
        )

        let flowRequestLocale: FlowRequestLocale =
            if let localizationSource = layoutsConfiguration.localization {
                .resolved(
                    await localizationStrategy.resolve(
                        for: preferredLocales,
                        from: localizationSource,
                        isLegacyVersion: false
                    )
                )
            } else {
                .unresolved
            }

        let schema = try await getUISchema(
            flowId: flow.id,
            flowLayoutVariant: layoutVariant,
            flowRequestLocale: flowRequestLocale,
            loadTimeout: loadTimeout,
            decodingConfiguration: .init(device: device.kind)
        )

        let resolvedLocaleId: String =
            switch flowRequestLocale {
            case .resolved(let value):
                value ?? AdaptyUILocalizationSource.globalDefaultLocale
            case .unresolved:
                await localizationStrategy.resolve(
                    for: preferredLocales,
                    from: schema
                ) ?? AdaptyUILocalizationSource.globalDefaultLocale
            }

        AdaptyUIBuilder.sendImageUrlsToObserver(schema, forLocalId: resolvedLocaleId)

        let envoriment = await Environment.fetchUIBuilderEnvironment(flow: flow)

        let extractLocaleTask = Task.detachedWithThrowsTyped(priority: .userInitiated) { () async throws(AdaptyError) -> AdaptyUIConfiguration in
            do {
                return try schema.extractUIConfiguration(
                    id: layout.id,
                    withLocaleId: resolvedLocaleId,
                    envoriment: envoriment
                )
            } catch {
                throw .extractAdaptyUIConfiguration(error)
            }
        }

        let configuration = try await extractLocaleTask.valueWithThrowsTyped()
        return (layoutVariant, configuration)
    }

    private func getUISchema(
        flowId: String,
        flowLayoutVariant: AdaptyFlow.LayoutVariant,
        flowRequestLocale: FlowRequestLocale,
        loadTimeout: AdaptyDuration,
        decodingConfiguration: AdaptyUISchema.DecodingConfiguration
    ) async throws(AdaptyError) -> AdaptyUISchema {
        let isTestUser = profileManager?.isTestUser ?? false
        let cacheKey = flowLayoutVariant.cacheKey

        if !isTestUser, let schema = await fetchLocalUISchema(cacheKey, flowRequestLocale: flowRequestLocale, decodingConfiguration) {
            return schema
        }

        let schema: AdaptyUISchema
        let data: Data

        do {
            (schema, data) = try await fetchBackendUISchema(
                flowId: flowId,
                flowLayoutVariant: flowLayoutVariant,
                flowRequestLocale: flowRequestLocale,
                loadTimeout: loadTimeout,
                disableServerCache: isTestUser,
                decodingConfiguration: decodingConfiguration
            )
            log.verbose("UI schema source = backend (\(flowLayoutVariant.id))")
        } catch {
            if isTestUser, let schema = await fetchLocalUISchema(cacheKey, flowRequestLocale: flowRequestLocale, decodingConfiguration) {
                return schema
            }
            throw error
        }

        Task.detached {
            do {
                try await Cache.write(
                    data,
                    key: cacheKey,
                    locale: flowRequestLocale.value.map { AdaptyLocale($0) },
                    dataVersion: 0
                )
            } catch {
                Log.cache.error("Failed to write schema to cache: \(error)")
            }
        }

        return schema
    }

    private func fetchLocalUISchema(
        _ key: Cache.ItemKey,
        flowRequestLocale: FlowRequestLocale,
        _ decodingConfiguration: AdaptyUISchema.DecodingConfiguration
    ) async -> AdaptyUISchema? {
        if let schema = await Cache.read(
            key,
            accept: flowRequestLocale.cacheReadAccept,
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
        flowLayoutVariant: AdaptyFlow.LayoutVariant,
        flowRequestLocale: FlowRequestLocale,
        loadTimeout: AdaptyDuration,
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
                    flowLayoutVariant: flowLayoutVariant,
                    flowLocale: flowRequestLocale.value,
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
                flowLayoutVariant: flowLayoutVariant,
                flowLocale: flowRequestLocale.value,
                disableServerCache: disableServerCache,
                decodingConfiguration: decodingConfiguration
            )
        } catch {
            throw error.asAdaptyError
        }
    }
}

private extension Adapty {
    enum FlowRequestLocale: Sendable {
        case unresolved
        case resolved(String?)

        var value: String? {
            switch self {
            case .unresolved: return nil
            case .resolved(let value): return value
            }
        }

        @Sendable func cacheReadAccept(_ meta: Cache.Meta) -> Bool {
            guard let existingLocale = meta.locale?.id else { return true }
            switch self {
            case .unresolved,
                 .resolved(.none): return false
            case .resolved(.some(let resolved)):
                return resolved == existingLocale
            }
        }
    }
}
