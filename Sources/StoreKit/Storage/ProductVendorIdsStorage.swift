//
//  ProductVendorIdsCache.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 30.09.2022.
//

import Foundation

protocol ProductVendorIdsStorage: AnyObject, Sendable {
    func setProductVendorIds(_: [String])
    func getProductVendorIds() -> [String]?
}