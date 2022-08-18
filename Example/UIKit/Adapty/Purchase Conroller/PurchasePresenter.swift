//
//  PurchasePresenter.swift
//  Adapty_Example
//
//  Created by Aleksey Goncharov on 16.08.2022.
//  Copyright © 2022 Adapty. All rights reserved.
//

import Adapty
import Combine
import Foundation

class PurchasePresenter: ObservableObject {
    private var cancellable = Set<AnyCancellable>()

    let isHorizontalLayout: Bool

    @Published var paywall: PaywallModel

    private var isUpToDate = false

    init(paywall: PaywallModel, isHorizontalLayout: Bool) {
        self.paywall = paywall
        self.isHorizontalLayout = isHorizontalLayout

        PurchasesObserver.shared.$paywall
            .sink(receiveValue: { [weak self] v in
                if let v = v {
                    self?.paywall = v
                }
            })
            .store(in: &cancellable)
    }

    func makePurchase(_ product: ProductModel, completion: ((Error?) -> Void)?) {
        PurchasesObserver.shared.makePurchase(product, completion: completion)
    }

    func restorePurchases(completion: ((Error?) -> Void)?) {
        PurchasesObserver.shared.restore(completion: completion)
    }

    func logShowPaywall() {
        Adapty.logShowPaywall(paywall)
    }
}
