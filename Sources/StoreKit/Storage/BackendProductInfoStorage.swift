//
//  BackendProductInfoStorage.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 30.09.2022.
//

import Foundation

private let log = Log.storage

@BackendProductInfoStorage.InternalActor
final class BackendProductInfoStorage {
    @globalActor
    actor InternalActor {
        package static let shared = InternalActor()
    }

    private enum Constants {
        static let productInfoStorageKey = "AdaptySDK_Cached_ProductVendorIds"
    }

    private static let userDefaults = Storage.userDefaults

    private static var allProductInfo: [String: BackendProductInfo]? = {
        do {
            return try userDefaults.getJSON([BackendProductInfo].self, forKey: Constants.productInfoStorageKey)?.asProductInfoByVendorId
        } catch {
            log.warn(error.localizedDescription)
            return nil
        }
    }()

    private static var allProductVendorIds: [String]? {
        guard let vendorIds = allProductInfo?.keys else { return nil }
        return Array(vendorIds)
    }

    var allProductVendorIds: [String]? { Self.allProductVendorIds }

    func set(allProductInfo: [BackendProductInfo]) {
        do {
            try Self.userDefaults.setJSON(allProductInfo, forKey: Constants.productInfoStorageKey)
            Self.allProductInfo = allProductInfo.asProductInfoByVendorId
            log.debug("Saving products info success.")
        } catch {
            log.error("Saving products info fail. \(error.localizedDescription)")
        }
    }

    func set(productInfo: [BackendProductInfo]) {
        let vendorIds = productInfo.map(\.self).map(\.vendorId)

        do {
            var allProductInfo = Self.allProductInfo ?? [:]
            for productInfo in productInfo {
                allProductInfo[productInfo.vendorId] = productInfo
            }
            try Self.userDefaults.setJSON(Array(allProductInfo.values), forKey: Constants.productInfoStorageKey)
            Self.allProductInfo = allProductInfo
            log.debug("Saving  product info (vendorIds: \(vendorIds)) success.")
        } catch {
            log.error("Saving  product info (vendorIds: \(vendorIds)) fail. \(error.localizedDescription)")
        }
    }

    static func clear() {
        allProductInfo = nil
        userDefaults.removeObject(forKey: Constants.productInfoStorageKey)
        log.debug("Clear products info.")
    }
}

extension Sequence<BackendProductInfo> {
    var asProductInfoByVendorId: [String: BackendProductInfo] {
        Dictionary(map { ($0.vendorId, $0) }, uniquingKeysWith: { _, second in
            second
        })
    }
}
