//
//  BackendProductStatesStorage+UserDefaults.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 07.10.2022.
//

import Foundation

extension UserDefaults: BackendProductStatesStorage {
    fileprivate enum Constants {
        static let backendProductStatesStorageKey = "AdaptySDK_Cached_Products"
    }

    func setBackendProductStates(_ products: VH<[BackendProductState]>) {
        do {
            try setJSON(products, forKey: Constants.backendProductStatesStorageKey)
            Log.debug("UserDefaults: Save products success.")
        } catch {
            Log.error("UserDefaults: Save products failed. \(error.localizedDescription)")
        }
    }

    func getBackendProductStates() -> VH<[BackendProductState]>? {
        do {
            return try getJSON(VH<[BackendProductState]>.self, forKey: Constants.backendProductStatesStorageKey)
        } catch {
            Log.warn(error.localizedDescription)
            return nil
        }
    }

    func clearBackendProducts() {
        Log.debug("UserDefaults: Clear products.")
        removeObject(forKey: Constants.backendProductStatesStorageKey)
    }
}
