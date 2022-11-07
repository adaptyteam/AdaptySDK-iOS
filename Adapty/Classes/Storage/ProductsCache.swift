//
//  BackendProductsCache.swift
//  Adapty
//
//  Created by Aleksei Valiano on 30.09.2022.
//

import Foundation

protocol BackendProductsStorage {
    func setBackendProducts(_: VH<[BackendProduct]>)
    func getBackendProducts() -> VH<[BackendProduct]>?
}

final class ProductsCache {
    private let storage: BackendProductsStorage
    private var products: VH<[String: BackendProduct]>?

    init(storage: BackendProductsStorage) {
        self.storage = storage
        products = storage.getBackendProducts().map { VH($0.value.asDictionary, hash: $0.hash) }
    }

    func getProduct(byId id: String) -> BackendProduct? { products?.value[id] }

    var productsHash: String? { products?.hash }

    func setProducts(_ products: VH<[BackendProduct]>) {
        var updated = false
        let array = products.value.map { product -> BackendProduct in
            guard let cached = self.products?.value[product.vendorId] else {
                updated = true
                return product
            }
            if product.version > cached.version {
                updated = true
                return product
            } else {
                return cached
            }
        }
        guard updated else { return }

        self.products = VH(array.asDictionary, hash: products.hash)
        storage.setBackendProducts(VH(array, hash: products.hash))
    }
}

extension ProductsCache {
    func getProducts(byIds ids: [String]) -> [BackendProduct] {
        guard let products = products?.value else { return [] }
        return ids.compactMap { products[$0] }
    }
}
