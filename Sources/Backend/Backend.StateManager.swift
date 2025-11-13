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
        private let executor: StateExecutor

        private var mainBaseUrlIndex: Int
        var currentState: BackendState
        private var storage = BackendStateStorage()
        private var syncing: Task<Void, Never>?
        private var lastUnavailableError: BackendUnavailableError?
        private var uaLastUnavailableError: BackendUnavailableError?

        init(with configuration: AdaptyConfiguration) {
            let backend = configuration.backend
            apiKeyPrefix = configuration.apiKeyPrefix
            cluster = backend.cluster
            devBaseUrls = backend.devBaseUrls

            executor = StateExecutor(
                baseUrl: devBaseUrls[StateExecutor.kind, with: cluster],
                session: .init(configuration: FallbackHTTPConfiguration(with: configuration))
            )

            if let state = storage.state {
                currentState = state
            } else {
                let state = BackendState.createDefault()
                storage.set(state: state)
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
            let kind = StateExecutor.kind
            try checkIsBlocked(kind)
            do {
                currentState = try await executor.fetchBackendState(
                    apiKeyPrefix: apiKeyPrefix
                )
                storage.set(state: currentState)
                mainBaseUrlIndex = 0
            } catch {
                currentState = currentState.extended()
                storage.set(state: currentState)
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
            guard case .backend(_, _, _, _, _, let error) = error, let error = error as? BackendUnavailableError else {
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
        case .network(_, _, _, error: _):
            false
        case .decoding(_, _, statusCode: _, headers: _, metrics: _, error: _):
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

extension Backend.StateManager {
    private func checkIsBlocked(_ request: BackendRequest, for kind: AdaptyServerKind) throws(BackendUnavailableError) {
        try checkIsBlocked(kind)
        guard kind == .main else { return }
        // TODO:
    }

    func fetchCurrentState() async -> BackendState {
        if currentState.isExpired {
            await sync()
        }
        return currentState
    }

    func baseUrl(_ request: BackendRequest, for kind: AdaptyServerKind) async throws(BackendUnavailableError) -> URL {
        try checkIsBlocked(request, for: kind)
        guard kind == .main else {
            return devBaseUrls[kind, with: cluster]
        }
        if let url = devBaseUrls?[kind] { return url }

        if currentState.isExpired {
            await sync()
        }

        guard let url = currentState.mainBaseUrl(by: cluster, withIndex: mainBaseUrlIndex) else {
            throw .blockedUntil(currentState.expiresAt)
        }
        return url
    }
}
