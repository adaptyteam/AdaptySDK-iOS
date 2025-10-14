//
//  Adapty+SyncIPv4.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.12.2023
//

import Foundation

extension AdaptyConfiguration {
    @AdaptyActor
    static var ipAddressCollectionDisabled = Self.default.ipAddressCollectionDisabled
}

extension Environment.Device {
    @AdaptyActor
    static var ipV4Address: String?
}

extension Adapty {
    private static var syncIPv4Started = false

    func startSyncIPv4OnceIfNeeded() {
        guard !AdaptyConfiguration.ipAddressCollectionDisabled,
              Environment.Device.ipV4Address == nil,
              !Adapty.syncIPv4Started
        else { return }

        Adapty.syncIPv4Started = true

        Task.detached(priority: .utility) { @AdaptyActor @Sendable [weak self] in
            defer { Adapty.syncIPv4Started = false }
            let value = try await Adapty.cachedIPv4OrFetch()
            _ = try await self?.createdProfileManager.updateProfile(
                params: AdaptyProfileParameters(ipV4Address: value)
            )
        }
    }

    private static func cachedIPv4OrFetch() async throws -> String {
        if let value = Environment.Device.ipV4Address { return value }
        let value = try await fetchIPv4()
        Environment.Device.ipV4Address = value
        return value
    }

    private static func fetchIPv4() async throws -> String {
        var attemptsCount: UInt64 = 0
        while !Task.isCancelled {
            do {
                let (data, _) = try await URLSession.shared.data(from: URL(string: "https://api.ipify.org?format=json")!)
                struct FetchIPv4Response: Decodable { let ip: String }
                let response = try JSONDecoder().decode(FetchIPv4Response.self, from: data)
                return response.ip
            } catch {
                guard let error = error as? URLError, error.shouldRetry else { throw error }
                attemptsCount += 1
                try await Task.sleep(duration: .seconds(min(attemptsCount, 10)))
            }
        }
        throw CancellationError()
    }
}

private extension URLError {
    var shouldRetry: Bool {
        switch self.code {
        case .timedOut,
             .cannotFindHost,
             .cannotConnectToHost,
             .networkConnectionLost,
             .dnsLookupFailed,
             .notConnectedToInternet,
             .resourceUnavailable,
             .backgroundSessionWasDisconnected:
            return true
        default:
            return false
        }
    }
}
