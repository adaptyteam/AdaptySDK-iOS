//
//  NetworkStateStorage.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 04.11.2025.
//

import Foundation

private let log = Log.storage

@BackendActor
final class BackendStateStorage {
    private enum Constants {
        static let networkStateKey = "AdaptySDK_network_state"
    }

    private static let userDefaults = Storage.userDefaults

    private static var state: BackendState? {
        do {
            return try userDefaults.getJSON(BackendState.self, forKey: Constants.networkStateKey)
        } catch {
            log.warn(error.localizedDescription)
            return nil
        }
    }

    private static func set(state: BackendState) {
        do {
            try userDefaults.setJSON(state, forKey: Constants.networkStateKey)
            log.debug("saving networkState success.")
        } catch {
            log.error("saving networkState fail. \(error.localizedDescription)")
        }
    }

    var state: BackendState? {
        Self.state
    }

    func set(state: BackendState) {
        Self.set(state: state)
    }
}
