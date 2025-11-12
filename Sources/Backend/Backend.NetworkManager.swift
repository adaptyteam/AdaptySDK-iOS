//
//  Backend.NetworkManager.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 02.11.2025.
//

import Foundation

extension Backend {
    @BackendActor
    final class NetworkManager {
        static let serverKind = AdaptyServerKind.fallback

        private let apiKeyPrefix: String

        private let cluster: AdaptyServerCluster
        private let devBaseUrls: [AdaptyServerKind: URL]?
        private let executor: NetworkExecutor

        private var mainBaseUrlIndex: Int
        var currentState: NetworkState
        private var storage = NetworkStateStorage()
        private var syncing: Task<Void, Never>?
        private var lastUnavailableError: BackendUnavailableError?
        private var uaLastUnavailableError: BackendUnavailableError?

        init(with configuration: AdaptyConfiguration) {
            let backend = configuration.backend
            apiKeyPrefix = configuration.apiKeyPrefix
            cluster = backend.cluster
            devBaseUrls = backend.devBaseUrls

            executor = NetworkExecutor(
                baseUrl: Self.serverKind.baseUrl(dev: devBaseUrls, by: cluster),
                session: .init(configuration: FallbackHTTPConfiguration(with: configuration)),
                kind: Self.serverKind
            )

            if let state = storage.networkState {
                currentState = state
            } else {
                let state = NetworkState.default
                storage.setNetworkState(state)
                currentState = state
            }
            mainBaseUrlIndex = 0
        }

        private func checkIsBlocked(_ kind: AdaptyServerKind) throws(BackendUnavailableError) {
            guard let lastUnavailableError else {
                if kind == .ua, let uaLastUnavailableError, uaLastUnavailableError.isBlocked {
                    throw uaLastUnavailableError
                }
                return
            }
            switch lastUnavailableError {
            case .unauthorized:
                throw lastUnavailableError
            case .blockedUntil:
                if kind == .ua {
                    guard let uaLastUnavailableError, uaLastUnavailableError.isBlocked else { return }
                    throw uaLastUnavailableError
                } else {
                    guard lastUnavailableError.isBlocked else { return }
                    throw lastUnavailableError
                }
            }
        }

        private func sync() async {
            let task: Task<Void, Never>
            if let syncing {
                task = syncing
            } else {
                task = Task.detached { try? await self.fetch() }
                syncing = task
            }
            await task.value
        }

        private func fetch() async throws {
            let kind = executor.kind
            try checkIsBlocked(kind)
            do {
                let config = try await executor.fetchNetworkConfiguration(
                    apiKeyPrefix: apiKeyPrefix
                )
                currentState = NetworkState.create(from: config)
                storage.setNetworkState(currentState)
                mainBaseUrlIndex = 0
            } catch {
                currentState = currentState.extended()
                storage.setNetworkState(currentState)
                _ = handleNetworkError(kind, error)
                throw error
            }
        }

        func handleNetworkState(
            _ kind: AdaptyServerKind,
            _ baseUrl: URL,
            _ error: HTTPError
        ) {
            let handled = handleNetworkError(kind, error)
            guard !handled, kind == .main, error.isUnavailableBaseUrl else { return }
            mainBaseUrlIndex += 1
        }

        private func handleNetworkError(
            _ kind: AdaptyServerKind,
            _ error: HTTPError
        ) -> Bool {
            guard case .backend(let endpoint, let source, let statusCode, let headers, let metrics, let error) = error, let error = error as? BackendUnavailableError else {
                return false
            }
            switch kind {
            case .main:
                lastUnavailableError = lastUnavailableError.merge(other: error)
                return true
            case .ua:
                uaLastUnavailableError = uaLastUnavailableError.merge(other: error)
                return true
            default:
                return false
            }
        }
    }
}

extension BackendUnavailableError? {
    func merge(other: BackendUnavailableError?) -> BackendUnavailableError? {
        guard let other else { return self }
        guard let self else { return other }

        switch (self, other) {
        case (.unauthorized, _):
            return self
        case (_, .unauthorized):
            return other
        case (.blockedUntil(let selfData), .blockedUntil(let otherData)):
            guard let otherData else { return self }
            guard let selfData, selfData < otherData else { return other }
            return self
        }
    }
}

extension BackendUnavailableError {
    var isBlocked: Bool {
        switch self {
        case .unauthorized:
            return true
        case .blockedUntil(let date):
            guard let date else { return false }
            return Date() < date
        }
    }
}

extension HTTPError {
    var isUnavailableBaseUrl: Bool {
        switch self {
        case .perform:
            false
        case .network(_, _, _, error: let error):
            false
        case .decoding(_, _, statusCode: let statusCode, headers: let headers, metrics: let metrics, error: let error):
            false
        case .backend(_, _, let statusCode, _, _, _):
            switch statusCode {
            case 500 ... 599:
                true
            default:
                false
            }
        }
    }
}

extension Backend.NetworkManager {
    private func checkIsBlocked(_ request: BackendRequest, for kind: AdaptyServerKind) throws(BackendUnavailableError) {
        try checkIsBlocked(kind)
        guard kind == .main else { return }
        // TODO:
    }

    func fetchCurrentState() async -> NetworkState {
        if currentState.isExpired {
            try? await sync()
        }
        return currentState
    }

    func baseUrl(_ request: BackendRequest, for kind: AdaptyServerKind) async throws(BackendUnavailableError) -> URL {
        try checkIsBlocked(request, for: kind)
        guard kind == .main else {
            return kind.baseUrl(dev: devBaseUrls, by: cluster)
        }
        if let url = devBaseUrls?[kind] { return url }

        if currentState.isExpired {
            try? await sync()
        }

        guard let url = currentState.mainBaseUrl(by: cluster, withIndex: mainBaseUrlIndex) else {
            throw .blockedUntil(currentState.expiresAt)
        }
        return url
    }
}
