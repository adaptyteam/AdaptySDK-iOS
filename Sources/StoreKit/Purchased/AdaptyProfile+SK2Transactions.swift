//
//  AdaptyProfile+StoreKit.Transaction.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 10.08.2025.
//

import StoreKit

private let log = Log.productManager

extension AdaptyProfile {
    func added(transactions: [StoreKit.Transaction], productManager: ProductsManager) async -> AdaptyProfile {
        guard !transactions.isEmpty else { return self }

        var accessLevels = [AdaptyProfile.AccessLevel]()

        let products = try? await productManager.fetchProducts(
            ids: Set(transactions.map(\.productID)),
            fetchPolicy: .returnCacheDataElseLoad
        )

        for transaction in transactions {
            let product = products?.first(where: { $0.id == transaction.productID })
            guard let productInfo = await productManager.getProductInfo(vendorId: transaction.productID) else {
                log.warn("Not found product info (productVendorId:\(transaction.productID))")
                continue
            }
            guard let accessLevel = await AdaptyProfile.AccessLevel(
                id: productInfo.accessLevelId,
                transaction: transaction,
                product: product,
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
