//
//  BackendProductsStorage+UserDefaults.swift
//  Adapty
//
//  Created by Aleksei Valiano on 07.10.2022.
//

import Foundation

extension UserDefaults: BackendProductsStorage {
    fileprivate enum Constants {
        static let backendProductsStorageKey = "AdaptySDK_Cached_Products"
    }

    func setBackendProducts(_ products: VH<[BackendProduct]>) {
        do {
            let data = try Backend.encoder.encode(products)
            Log.debug("UserDefaults: Save products success.")
            set(data, forKey: Constants.backendProductsStorageKey)
        } catch {
            Log.error("UserDefaults: Save products failed. \(error.localizedDescription)")
        }
    }

    func getBackendProducts() -> VH<[BackendProduct]>? {
        guard let data = data(forKey: Constants.backendProductsStorageKey) else { return nil }
        do {
            return try Backend.decoder.decode(VH<[BackendProduct]>.self, from: data)
        } catch {
            Log.warn(error.localizedDescription)
            return nil
        }
    }

    func clearBackendProducts() {
        Log.debug("UserDefaults: Clear products.")
        removeObject(forKey: Constants.backendProductsStorageKey)
    }
}
