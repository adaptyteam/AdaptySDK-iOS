//
//  CrossPlacementStorage.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 21.08.2025.
//

import Foundation

private let log = Log.crossAB

@AdaptyActor
final class CrossPlacementStorage {
    private enum Constants {
        static let crossPlacementStateKey = "AdaptySDK_Cross_Placement_State"
    }

    private static let userDefaults = Storage.userDefaults

    private static var crossPlacementState: CrossPlacementState? = {
        do {
            return try userDefaults.getJSON(CrossPlacementState.self, forKey: Constants.crossPlacementStateKey)
        } catch {
            log.warn(error.localizedDescription)
            return nil
        }
    }()

    var state: CrossPlacementState? { Self.crossPlacementState }

    func setState(_ value: CrossPlacementState) {
        do {
            try Self.userDefaults.setJSON(value, forKey: Constants.crossPlacementStateKey)
            Self.crossPlacementState = value
            log.verbose("saving crossPlacementState success = \(value)")
        } catch {
            log.error("saving crossPlacementState fail. \(error.localizedDescription)")
        }
    }

    static func clear() {
        userDefaults.removeObject(forKey: Constants.crossPlacementStateKey)
        crossPlacementState = nil
        log.verbose("clear CrossPlacementStorage")
    }
}
