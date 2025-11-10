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
        let configuration: Backend.Configuration
        var mainBaseUrlIndex: Int
        var currentState: NetworkState
        var isBlocked = false

        init(with configuration: Backend.Configuration) {
            self.configuration = configuration
            self.currentState = NetworkConfiguration.defaultState
            self.mainBaseUrlIndex = 0
        }
    }
}

extension Backend.NetworkManager {
    private func checkIsBlocked() throws(BackendPerformError) {
        guard isBlocked else { return }
        throw .blocked
    }

    private func checkIsBlocked(_ endpoint: HTTPEndpoint) throws(BackendPerformError) {
        try checkIsBlocked()
        // TODO:
    }

    func fetchCurrentState() async -> NetworkState {
        guard currentState.isExpired else { return currentState }

        return currentState
    }

    func mainBaseUrl(_ endpoint: HTTPEndpoint) async throws(BackendPerformError) -> URL {
        try checkIsBlocked(endpoint)
        if let url = configuration.mainBaseUrl { return url }
        guard let url = currentState.mainBaseUrl(by: configuration.cluster, withIndex: mainBaseUrlIndex) else {
            throw .urlsIsEmpty
        }
        return url
    }

    func fallbackBaseUrl(_ endpoint: HTTPEndpoint) async throws(BackendPerformError) -> URL {
        try checkIsBlocked(endpoint)
        if let url = configuration.fallbackBaseUrl { return url }
        return NetworkConfiguration.fallbackBaseUrl(by: configuration.cluster)
    }

    func configsBaseUrl(_ endpoint: HTTPEndpoint) async throws(BackendPerformError) -> URL {
        try checkIsBlocked(endpoint)
        if let url = configuration.configsBaseUrl { return url }
        return NetworkConfiguration.configsBaseUrl(by: configuration.cluster)
    }

    func uaBaseUrl(_ endpoint: HTTPEndpoint) async throws(BackendPerformError) -> URL {
        try checkIsBlocked(endpoint)
        if let url = configuration.uaBaseUrl { return url }
        return NetworkConfiguration.uaBaseUrl(by: configuration.cluster)
    }
}
