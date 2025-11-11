//
//  Backend.NetworrkManager.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 02.11.2025.
//

import Foundation

extension Backend {
    @BackendActor
    final class NetworkManager {
        private let cluster: AdaptyServerCluster
        private let devBaseUrl: URL?
        private let fallbackBaseUrl: URL
        private let configsBaseUrl: URL
        private let uaBaseUrl: URL
//        private let executor: BackendExecutor

        private var mainBaseUrlIndex: Int
        var currentState: NetworkState
        private var storage = NetworkStateStorage()
        private var syncing: Task<Void, Never>?
        private var isBlocked = false

        init(with configuration: Backend.Configuration) {
            cluster = configuration.cluster
            devBaseUrl = configuration.mainBaseUrl
            fallbackBaseUrl = configuration.fallbackBaseUrl ?? NetworkConfiguration.fallbackBaseUrl(by: configuration.cluster)
            configsBaseUrl = configuration.configsBaseUrl ?? NetworkConfiguration.configsBaseUrl(by: configuration.cluster)
            uaBaseUrl = configuration.uaBaseUrl ?? NetworkConfiguration.uaBaseUrl(by: configuration.cluster)

//            executor =
            if let state = storage.networkState {
                currentState = state
            } else {
                let state = NetworkConfiguration.defaultState
                storage.setNetworkState(state)
                currentState = state
            }
            mainBaseUrlIndex = 0
        }

        private func checkIsBlocked() throws(BackendPerformError) {
            guard isBlocked else { return }
            throw .blocked
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
            try checkIsBlocked()
        }
    }
}

extension Backend.NetworkManager {
    private func checkIsBlocked(_ request: BackendRequest) throws(BackendPerformError) {
        try checkIsBlocked()
        // TODO:
    }

    func fetchCurrentState() async -> NetworkState {
        guard currentState.isExpired else { return currentState }

        return currentState
    }

    func mainBaseUrl(_ request: BackendRequest) async throws(BackendPerformError) -> URL {
        try checkIsBlocked(request)
        if let url = devBaseUrl { return url }
        guard let url = currentState.mainBaseUrl(by: cluster, withIndex: mainBaseUrlIndex) else {
            throw .urlsIsEmpty
        }
        return url
    }

    func fallbackBaseUrl(_ request: BackendRequest) async throws(BackendPerformError) -> URL {
        try checkIsBlocked(request)
        return fallbackBaseUrl
    }

    func configsBaseUrl(_ request: BackendRequest) async throws(BackendPerformError) -> URL {
        try checkIsBlocked(request)
        return configsBaseUrl
    }

    func uaBaseUrl(_ request: BackendRequest) async throws(BackendPerformError) -> URL {
        try checkIsBlocked(request)
        return uaBaseUrl
    }
}

extension Backend.NetworkManager {
    struct Executor: BackendExecutor {
        let session: HTTPSession
        let baseURLFor: @BackendActor @Sendable (BackendRequest) async throws -> URL

        init(baseUrl: URL, httpConfiguration: HTTPCodableConfiguration) {
            session = HTTPSession(configuration: httpConfiguration)
            baseURLFor = { _ in baseUrl }
        }
    }
}
