//
//  ProductVendorIdsStorage.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 30.09.2022.
//

import Foundation

private let log = Log.storage

@ProductVendorIdsStorage.InternalActor
final class ProductVendorIdsStorage: Sendable {
    @globalActor
    actor InternalActor {
        package static let shared = InternalActor()
    }

    private enum Constants {
        static let productVendorIdsStorageKey = "AdaptySDK_Cached_ProductVendorIds"
    }

    private static let userDefaults = Storage.userDefaults

    private static var allProductVendorIds: [String]? = {
        do {
            return try userDefaults.getJSON([String].self, forKey: Constants.productVendorIdsStorageKey)
        } catch {
            log.warn(error.localizedDescription)
            return nil
        }
    }()

    var allProductVendorIds: [String]? { Self.allProductVendorIds }

    func set(productVendorIds vendorIds: [String]) {
        do {
            try Self.userDefaults.setJSON(vendorIds, forKey: Constants.productVendorIdsStorageKey)
            Self.allProductVendorIds = vendorIds
            log.debug("Saving vendor product ids success.")
        } catch {
            log.error("Saving vendor product ids fail. \(error.localizedDescription)")
        }
    }

    static func clear() {
        allProductVendorIds = nil
        userDefaults.removeObject(forKey: Constants.productVendorIdsStorageKey)
        log.debug("Clear vendor product ids.")
    }
}
