//
//  PaywallService.swift
//  Adapty-Demo
//
//  Created by Elena Gordienko on 01.08.22.
//  Copyright © 2022 Adapty. All rights reserved.
//

import Adapty
import Foundation
import SwiftUI

final class PaywallService: ObservableObject {
    @Published var paywall: PaywallModel? {
        didSet {
            paywallViewModel = model(for: paywall)
        }
    }
    
    var paywallViewModel: PaywallViewModel = PaywallService.defaultPaywall
        
    // MARK: - Paywalls
    
    func getPaywalls(completion: ((Error?) -> Void)? = nil) {
        Adapty.getPaywalls(forceUpdate: true) { [weak self] paywalls, products, error in
            if error == nil {
                self?.paywall = paywalls?.first(where: { $0.developerId == "YOUR_PAYWALL_ID" })
            }
            completion?(error)
        }
    }
    
    func logPaywallDisplay() {
        paywall.map { Adapty.logShowPaywall($0) }
    }
}

// MARK: - Utils

extension PaywallService {
    static var defaultPaywall: PaywallViewModel {
        .init(
            iconName: Image.Gallery.Name.duck,
            description: "Premium users bring our company more money!",
            buyActionTitle: "Give us money",
            cancelActionTitle: "Not today!",
            restoreActionTitle: "Restore purchases"
        )
    }
    
    private func model(for paywall: PaywallModel?) -> PaywallViewModel {
        let restorePurchasesActionTitle = "Restore purchases"
        guard
            let currentPaywall = paywall,
            let iconName = currentPaywall.customPayload?["icon_name"] as? String,
            let description = currentPaywall.customPayload?["header_text"] as? String,
            let buyActionTitle = currentPaywall.customPayload?["buy_button_text"] as? String,
            let cancelActionTitle = currentPaywall.customPayload?["cancel_button_text"] as? String
        else {
            return PaywallService.defaultPaywall
        }
        return PaywallViewModel(
            iconName: iconName,
            description: description,
            buyActionTitle: buyActionTitle,
            cancelActionTitle: cancelActionTitle,
            restoreActionTitle: restorePurchasesActionTitle
        )
    }
}
