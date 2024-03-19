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

    func setProductVendorIds(_ vendorIds: VH<[String]>) {
        do {
            let data = try Backend.encoder.encode(vendorIds)
            Log.debug("UserDefaults: Saving vendor product ids success.")
            set(data, forKey: Constants.productVendorIdsStorageKey)
        } catch {
            Log.error("UserDefaults: Saving vendor product ids fail. \(error.localizedDescription)")
        }
    }

    func getProductVendorIds() -> VH<[String]>? {
        guard let data = data(forKey: Constants.productVendorIdsStorageKey) else { return nil }
        do {
            return try Backend.decoder.decode(VH<[String]>.self, from: data)
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
