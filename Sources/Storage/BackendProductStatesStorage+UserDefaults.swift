//
//  BackendProductStatesStorage+UserDefaults.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 07.10.2022.
//

import Foundation

private let log = Log.storage

extension UserDefaults: BackendProductStatesStorage {
    fileprivate enum Constants {
        static let backendProductStatesStorageKey = "AdaptySDK_Cached_Products"
    }

    func setBackendProductStates(_ products: VH<[BackendProductState]>) {
        do {
            try setJSON(products, forKey: Constants.backendProductStatesStorageKey)
            log.debug("Save products success.")
        } catch {
            log.error("Save products failed. \(error.localizedDescription)")
        }
    }

    func getBackendProductStates() -> VH<[BackendProductState]>? {
        do {
            return try getJSON(VH<[BackendProductState]>.self, forKey: Constants.backendProductStatesStorageKey)
        } catch {
            log.warn(error.localizedDescription)
            return nil
        }
    }

    func clearBackendProducts() {
        log.debug("Clear products.")
        removeObject(forKey: Constants.backendProductStatesStorageKey)
    }
}
