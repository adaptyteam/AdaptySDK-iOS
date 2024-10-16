//
//  BackendProductStatesStorage.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 30.09.2022.
//

import Foundation

private let log = Log.storage

@AdaptyActor
final class BackendProductStatesStorage: Sendable {
    private enum Constants {
        static let backendProductStatesStorageKey = "AdaptySDK_Cached_Products"
    }

    private static let userDefaults = Storage.userDefaults
    private static var products: VH<[String: BackendProductState]>? = {
        do {
            return try userDefaults.getJSON(VH<[BackendProductState]>.self, forKey: Constants.backendProductStatesStorageKey).map {
                $0.mapValue { $0.asDictionary }
            }
        } catch {
            log.warn(error.localizedDescription)
            return nil
        }

    }()

    func getBackendProductState(byId id: String) -> BackendProductState? { Self.products?.value[id] }

    func getBackendProductStates(byIds ids: [String]) -> [BackendProductState] {
        guard let products = Self.products?.value else { return [] }
        return ids.compactMap { products[$0] }
    }

    var productsHash: String? { Self.products?.hash }

    func setBackendProductStates(_ products: VH<[BackendProductState]>?) {
        guard let products else { return }
        var updated = false

        let array = products.mapValue {
            $0.map { product -> BackendProductState in
                guard let cached = Self.products?.value[product.vendorId] else {
                    updated = true
                    return product
                }
                if product.version >= cached.version {
                    updated = true
                    return product
                } else {
                    log.verbose("ProductStatesCache: saved product.version(\(product.version)) is older than cashed.version(\(cached.version) : \(product.vendorId)")
                    return cached
                }
            }
        }

        guard updated else { return }

        Self.products = array.mapValue { $0.asDictionary }

        do {
            try Self.userDefaults.setJSON(products, forKey: Constants.backendProductStatesStorageKey)
            log.debug("Save products success.")
        } catch {
            log.error("Save products failed. \(error.localizedDescription)")
        }
    }

    
    static func clear() {
        products = nil
        userDefaults.removeObject(forKey: Constants.backendProductStatesStorageKey)
        log.debug("Clear products.")
    }
}
