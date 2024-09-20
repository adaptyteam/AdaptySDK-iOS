//
//  PaywallsStorage.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 22.10.2022.
//

import Foundation

protocol PaywallsStorage: AnyObject, Sendable {
    func setPaywalls(_: [VH<AdaptyPaywall>])
    func getPaywalls() -> [VH<AdaptyPaywall>]?
}
