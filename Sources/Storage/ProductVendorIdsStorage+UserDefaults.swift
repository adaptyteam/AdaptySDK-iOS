//
//  ProductVendorIdsStorage+UserDefaults.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 07.10.2022.
//

import Foundation

private let log = Log.storage

extension UserDefaults: ProductVendorIdsStorage {
    fileprivate enum Constants {
        static let productVendorIdsStorageKey = "AdaptySDK_Cached_ProductVendorIds"
    }

    func setProductVendorIds(_ vendorIds: [String]) {
        do {
            try setJSON(vendorIds, forKey: Constants.productVendorIdsStorageKey)
            log.debug("Saving vendor product ids success.")
        } catch {
            log.error("Saving vendor product ids fail. \(error.localizedDescription)")
        }
    }

    func getProductVendorIds() -> [String]? {
        do {
            return try getJSON([String].self, forKey: Constants.productVendorIdsStorageKey)
        } catch {
            log.warn(error.localizedDescription)
            return nil
        }
    }

    func clearProductVendorIds() {
        log.debug("Clear vendor product ids.")
        removeObject(forKey: Constants.productVendorIdsStorageKey)
    }
}
