//
//  AdaptyProfile+SK2Transactions.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 10.08.2025.
//

import StoreKit

private let log = Log.sk2ProductManager

extension AdaptyProfile {
    func added(transactions: [SK2Transaction], productManager: SK2ProductsManager) async -> AdaptyProfile {
        guard !transactions.isEmpty else { return self }

        var accessLevels = [AdaptyProfile.AccessLevel]()

        let products = try? await productManager.fetchSK2Products(
            ids: Set(transactions.map { $0.unfProductId }),
            fetchPolicy: .returnCacheDataElseLoad
        )

        for transaction in transactions {
            let sk2Product = products?.first(where: { $0.id == transaction.unfProductId })
            guard let productInfo = await productManager.getProductInfo(vendorId: transaction.unfProductId) else {
                log.warn("Not found product info (productVendorId:\(transaction.unfProductId))")
                continue
            }
            guard let accessLevel = await AdaptyProfile.AccessLevel(
                id: productInfo.accessLevelId,
                sk2Transaction: transaction,
                sk2Product: sk2Product,
                backendPeriod: productInfo.period
            ) else { continue }

            accessLevels.append(accessLevel)
        }

        guard !accessLevels.isEmpty else { return self }
        return merge(accessLevels: accessLevels)
    }

    private func merge(accessLevels: [AccessLevel]) -> Self {
        var profile = self
        var resultAcessLevels = profile.accessLevels

        for newValue in accessLevels {
            var needSetNewValue = true

            if let oldValue = resultAcessLevels[newValue.id] {
                switch (oldValue.isLifetime, newValue.isLifetime) {
                case (true, _):
                    needSetNewValue = false
                case (false, true):
                    needSetNewValue = true
                case (false, false):
                    switch (oldValue.expiresAt, newValue.expiresAt) {
                    case (.some, nil):
                        needSetNewValue = false
                    case (nil, .some):
                        needSetNewValue = true
                    case (nil, nil):
                        needSetNewValue = !oldValue.isActive && newValue.isActive
                    case let (oldExpiresAt?, newExpiresAt?):
                        needSetNewValue = oldExpiresAt < newExpiresAt
                    }
                }
            }

            if needSetNewValue {
                resultAcessLevels[newValue.id] = newValue
            }
        }

        profile.accessLevels = resultAcessLevels
        return profile
    }
}
