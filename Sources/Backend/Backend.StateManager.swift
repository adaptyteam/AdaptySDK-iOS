//
//  Backend.StateManager.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 02.11.2025.
//

import Foundation

extension Backend {
    @BackendActor
    final class StateManager {
        private let apiKeyPrefix: String

        private let cluster: AdaptyServerCluster
        private let devBaseUrls: [AdaptyServerKind: URL]?
        private let session: HTTPSession

        private var mainBaseUrlIndex: Int
        var currentState: BackendState
        private var storage = BackendStateStorage()
        private var syncing: Task<Void, Never>?
        private var serverBlockedByKind = Set<AdaptyServerKind>()
        private var requestBlockedUntil = [BackendRequestName: Date]()

        init(with configuration: AdaptyConfiguration) {
            let backend = configuration.backend
            apiKeyPrefix = configuration.apiKeyPrefix
            cluster = backend.cluster
            devBaseUrls = backend.devBaseUrls
            session = .init(configuration: FallbackHTTPConfiguration(with: configuration))

            if let state = storage.state {
                currentState = state
            } else {
                let state = BackendState.createDefault()
                storage.set(state: state)
                currentState = state
            }
            mainBaseUrlIndex = 0
        }

        private func syncState() async {
            let task: Task<Void, Never>
            if let syncing {
                task = syncing
            } else {
                task = Task.detached { try? await self.fetchState() }
                syncing = task
            }
            await task.value
        }

        private func fetchState() async throws {
            defer { syncing = nil }

            try checkIsBlocked(for: .fallback)
            let baseUrl = devBaseUrls[.fallback, with: cluster]

            do {
                currentState = try await DefaultBackendExecutor.fetchBackendState(
                    withBaseUrl: baseUrl,
                    withSession: session,
                    apiKeyPrefix: apiKeyPrefix
                )
                storage.set(state: currentState)
                mainBaseUrlIndex = 0
            } catch {
                currentState = currentState.extended()
                storage.set(state: currentState)
                throw error
            }
        }

        private func checkIsBlocked(
            for serverKind: AdaptyServerKind
        ) throws(BackendUnavailableError) {
            switch serverKind {
            case .ua:
                guard !serverBlockedByKind.contains(.main),
                      !serverBlockedByKind.contains(serverKind)
                else { throw .unauthorized }
            default:
                guard !serverBlockedByKind.contains(.main) else { throw .unauthorized }
            }

            if serverKind == .main, !currentState.mainBaseUrlsExist(by: cluster) {
                throw .blockedUntil(currentState.expiresAt)
            }
        }

        private func checkIsBlocked(
            _ requestName: BackendRequestName,
            for serverKind: AdaptyServerKind
        ) throws(BackendUnavailableError) {
            try checkIsBlocked(for: serverKind)
            if serverKind != .fallback,
               let expiresAt = requestBlockedUntil[requestName], expiresAt > Date()
            {
                throw .blockedUntil(expiresAt)
            }
        }

        private func handleNetworkError(
            _ serverKind: AdaptyServerKind,
            _ requestName: BackendRequestName,
            _ error: HTTPError
        ) {
            guard case .backend(_, _, _, _, _, let error) = error,
                  let error = error as? BackendUnavailableError
            else { return }

            switch error {
            case .unauthorized:
                serverBlockedByKind.insert(serverKind)
            case .blockedUntil(let expiresAt):
                guard let expiresAt else { return }
                if let oldExpiresAt = requestBlockedUntil[requestName],
                   oldExpiresAt > expiresAt { return }
                requestBlockedUntil[requestName] = expiresAt
            }
        }

        private func handleIsServerUnavailable(
            _ serverKind: AdaptyServerKind,
            _ baseUrl: URL,
            _ error: HTTPError
        ) {
            guard serverKind == .main,
                  error.isServerUnavailable,
                  baseUrl == currentState.mainBaseUrl(by: cluster, withIndex: mainBaseUrlIndex)
            else { return }

            mainBaseUrlIndex += 1
        }
    }
}

extension Backend.StateManager {
    func handleNetworkState(
        _ serverKind: AdaptyServerKind,
        _ requestName: BackendRequestName,
        _ baseUrl: URL,
        _ error: HTTPError
    ) {
        handleNetworkError(serverKind, requestName, error)
        handleIsServerUnavailable(serverKind, baseUrl, error)
    }

    func fetchCurrentState() async -> BackendState {
        if currentState.isExpired {
            await syncState()
        }
        return currentState
    }

    func baseUrl(
        _ request: BackendRequest,
        for serverKind: AdaptyServerKind
    ) async throws(BackendUnavailableError) -> URL {
        try checkIsBlocked(request.requestName, for: serverKind)
        guard serverKind == .main else {
            return devBaseUrls[serverKind, with: cluster]
        }
        if let url = devBaseUrls?[serverKind] { return url }

        if currentState.isExpired {
            await syncState()
        }

        guard let url = currentState.mainBaseUrl(by: cluster, withIndex: mainBaseUrlIndex) else {
            throw .blockedUntil(currentState.expiresAt)
        }
        return url
    }
}
