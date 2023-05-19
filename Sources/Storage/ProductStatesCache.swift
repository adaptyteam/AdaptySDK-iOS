//
//  ProductStatesCache.swift
//  Adapty
//
//  Created by Aleksei Valiano on 30.09.2022.
//

import Foundation

protocol BackendProductStatesStorage {
    func setBackendProductStates(_: VH<[BackendProductState]>)
    func getBackendProductStates() -> VH<[BackendProductState]>?
}

final class ProductStatesCache {
    private let storage: BackendProductStatesStorage
    private var products: VH<[String: BackendProductState]>?

    init(storage: BackendProductStatesStorage) {
        self.storage = storage
        products = storage.getBackendProductStates().map { VH($0.value.asDictionary, hash: $0.hash) }
    }

    func getBackendProductState(byId id: String) -> BackendProductState? { products?.value[id] }

    func getBackendProductStates(byIds ids: [String]) -> [BackendProductState] {
        guard let products = products?.value else { return [] }
        return ids.compactMap { products[$0] }
    }

    var productsHash: String? { products?.hash }

    func setBackendProductStates(_ products: VH<[BackendProductState]>) {
        var updated = false
        let array = products.value.map { product -> BackendProductState in
            guard let cached = self.products?.value[product.vendorId] else {
                updated = true
                return product
            }
            if product.version >= cached.version {
                updated = true
                return product
            } else {
                Log.verbose("ProductStatesCache: saved product.version(\(product.version)) is older than cashed.version(\(cached.version) : \(product.vendorId)")
                return cached
            }
        }
        guard updated else { return }


        self.products = VH(array.asDictionary, hash: products.hash)
        storage.setBackendProductStates(VH(array, hash: products.hash))

   
    }
}
