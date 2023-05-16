//
//  ProductVendorIdsCache.swift
//  Adapty
//
//  Created by Aleksei Valiano on 30.09.2022.
//

import Foundation

protocol ProductVendorIdsStorage {
    func setProductVendorIds(_: VH<[String]>)
    func getProductVendorIds() -> VH<[String]>?
    var profileId: String { get }
}

final class ProductVendorIdsCache {
    private let storage: ProductVendorIdsStorage
    private(set) var allProductVendorIds: VH<[String]>?

    init(storage: ProductVendorIdsStorage) {
        self.storage = storage

        allProductVendorIds = storage.getProductVendorIds()
    }

    func setProductVendorIds(_ values: VH<[String]>) {
        allProductVendorIds = values
        storage.setProductVendorIds(values)
    }
}

extension ProductVendorIdsCache {
    var profileId: String { storage.profileId }
}
