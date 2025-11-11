//
//  NetworkStateStorage.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 04.11.2025.
//

import Foundation

private let log = Log.storage

@BackendActor
final class NetworkStateStorage {
    private enum Constants {
        static let networkStateKey = "AdaptySDK_network_state"
    }

    private static let userDefaults = Storage.userDefaults

    private static var networkState: NetworkState? {
        do {
            return try userDefaults.getJSON(NetworkState.self, forKey: Constants.networkStateKey)
        } catch {
            log.warn(error.localizedDescription)
            return nil
        }
    }

    private static func setNetworkState(_ state: NetworkState) {
        do {
            try userDefaults.setJSON(state, forKey: Constants.networkStateKey)
            log.debug("saving networkState success.")
        } catch {
            log.error("saving networkState fail. \(error.localizedDescription)")
        }
    }

    var networkState: NetworkState? {
        Self.networkState
    }

    func setNetworkState(_ state: NetworkState) {
        Self.setNetworkState(state)
    }
}
