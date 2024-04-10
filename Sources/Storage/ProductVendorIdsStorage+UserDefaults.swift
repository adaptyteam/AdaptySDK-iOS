//
//  ProductVendorIdsStorage+UserDefaults.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 07.10.2022.
//

import Foundation

extension UserDefaults: ProductVendorIdsStorage {
    fileprivate enum Constants {
        static let productVendorIdsStorageKey = "AdaptySDK_Cached_ProductVendorIds"
    }

    func setProductVendorIds(_ vendorIds: [String]) {
        do {
            try setJSON(vendorIds, forKey: Constants.productVendorIdsStorageKey)
            Log.debug("UserDefaults: Saving vendor product ids success.")
        } catch {
            Log.error("UserDefaults: Saving vendor product ids fail. \(error.localizedDescription)")
        }
    }

    func getProductVendorIds() -> [String]? {
        do {
            return try getJSON([String].self, forKey: Constants.productVendorIdsStorageKey)
        } catch {
            Log.warn(error.localizedDescription)
            return nil
        }
    }

    func clearProductVendorIds() {
        Log.debug("UserDefaults: Clear vendor product ids.")
        removeObject(forKey: Constants.productVendorIdsStorageKey)
    }
}
