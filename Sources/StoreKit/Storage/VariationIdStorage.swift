//
//  SK1QueueManager.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 25.10.2022
//

import StoreKit

protocol VariationIdStorage {
    func getVariationsIds() -> [String: String]?
    func setVariationsIds(_: [String: String])
    func getPersistentVariationsIds() -> [String: String]?
    func setPersistentVariationsIds(_: [String: String])
}
