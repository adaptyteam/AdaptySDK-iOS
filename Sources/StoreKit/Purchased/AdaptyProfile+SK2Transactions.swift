//
//  AdaptyProfile+SK2Transactions.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 10.08.2025.
//

import StoreKit

private let log = Log.sk2ProductManager

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptyProfile {
    func added(transactions: [SK2Transaction], productManager: SK2ProductsManager) async -> AdaptyProfile {
        guard !transactions.isEmpty else { return self }
        var accessLevels = [String: AdaptyProfile.AccessLevel]()
        let products = try? await productManager.fetchSK2Products(
            ids: Set(transactions.map { $0.unfProductID }),
            fetchPolicy: .returnCacheDataElseLoad
        )
        for transaction in transactions {
            let sk2Product = products?.first(where: { $0.id == transaction.unfProductID })
            guard let productInfo = await productManager.getProductInfo(vendorId: transaction.unfProductID) else {
                log.warn("Not found product info (productVendorId:\(transaction.unfProductID))")
                continue
            }
            guard let accessLevel = await AdaptyProfile.AccessLevel(
                sk2Transaction: transaction,
                sk2Product: sk2Product,
                backendPeriod: productInfo.period
            ) else { continue }
            accessLevels[productInfo.accessLevelId] = accessLevel
        }
        guard !accessLevels.isEmpty else { return self }
        return merge(accessLevels: accessLevels)
    }

    private func merge(accessLevels: [String: AccessLevel]) -> Self {
        var profile = self
        var resultAcessLevels = profile.accessLevels
        for (accessLevelId, newValue) in accessLevels {
            var needSetNewValue = true
            if let oldValue = resultAcessLevels[accessLevelId] {
                switch (oldValue.expiresAt, newValue.expiresAt) {
                case (.some, nil):
                    needSetNewValue = false
                case (nil, nil):
                    needSetNewValue = !oldValue.isActive && newValue.isActive
                case (nil, .some):
                    needSetNewValue = true
                case let (oldExpiresAt?, newExpiresAt?):
                    needSetNewValue = oldExpiresAt < newExpiresAt
                }
            }

            if needSetNewValue {
                resultAcessLevels[accessLevelId] = newValue
            }
        }
        profile.accessLevels = resultAcessLevels
        return profile
    }
}
