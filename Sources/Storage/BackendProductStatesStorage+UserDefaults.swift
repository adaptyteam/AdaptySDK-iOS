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
            let data = try Backend.encoder.encode(products)
            Log.debug("UserDefaults: Save products success.")
            set(data, forKey: Constants.backendProductStatesStorageKey)
        } catch {
            Log.error("UserDefaults: Save products failed. \(error.localizedDescription)")
        }
    }

    func getBackendProductStates() -> VH<[BackendProductState]>? {
        guard let data = data(forKey: Constants.backendProductStatesStorageKey) else { return nil }
        do {
            return try Backend.decoder.decode(VH<[BackendProductState]>.self, from: data)
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
