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
    @Published var paywall: AdaptyPaywall?
    @Published var paywallProducts: [AdaptyPaywallProduct]?
    @Published var paywallViewModel: PaywallViewModel?
        
    // MARK: - Paywalls
    
    func getPaywalls(completion: ((Error?) -> Void)? = nil) {
        reset()
        Adapty.getPaywall("YOUR_PAYWALL_ID") { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(paywall):
                self.paywall = paywall
                self.getPaywallProducts(for: paywall, completion: completion)
            case let .failure(error):
                completion?(error)
            }
        }
    }
    
    private func getPaywallProducts(
        for currentPaywall: AdaptyPaywall,
        completion: ((Error?) -> Void)? = nil
    ) {
        let remoteConfig = currentPaywall.remoteConfig
        // `default` fetch policy allows to fetch products faster,
        // without waiting for their `introductoryOfferEligibility` statuses
        Adapty.getPaywallProducts(paywall: currentPaywall, fetchPolicy: .default) { [weak self] result in
            switch result {
            case let .success(products):
                // If there is a product with `introductoryOfferEligibility` equal to `unknown`,
                // we can refetch products again with `.waitForReceiptValidation` fetch policy.
                // For more info:
                // https://docs.adapty.io/docs/ios-displaying-products#products-fetch-policy-and-intro-offer-eligibility
                guard !products.contains(where: { $0.introductoryOfferEligibility == .unknown }) else {
                    self?.getPaywallProductsEnsuringEligibility(for: currentPaywall) { [weak self] updatedProducts in
                        self?.updateProducts(updatedProducts ?? products, remoteConfig: remoteConfig)
                        completion?(nil)
                    }
                    return
                }
                self?.updateProducts(products, remoteConfig: remoteConfig)
                completion?(nil)
            case let .failure(error):
                completion?(error)
            }
        }
    }
    
    private func getPaywallProductsEnsuringEligibility(
        for currentPaywall: AdaptyPaywall,
        completion: @escaping (([AdaptyPaywallProduct]?) -> Void)
    ) {
        Adapty.getPaywallProducts(paywall: currentPaywall, fetchPolicy: .waitForReceiptValidation) { result in
            var newProducts: [AdaptyPaywallProduct]?
            if case let .success(eligibleProducts) = result { newProducts = eligibleProducts }
            completion(newProducts)
        }
    }
    
    private func updateProducts(_ products: [AdaptyPaywallProduct], remoteConfig: [String: Any]?) {
        paywallProducts = products
        paywallViewModel = model(for: remoteConfig, products: products)
    }

    func logPaywallDisplay() {
        paywall.map { Adapty.logShowPaywall($0) }
    }
    
    func reset() {
        paywall = nil
        paywallProducts = nil
        paywallViewModel = nil
    }
}

// MARK: - Utils

private extension PaywallService {
    func model(for config: [String: Any]?, products: [AdaptyPaywallProduct]) -> PaywallViewModel? {
        guard !products.isEmpty else { return nil }
        let payloadDTO = decodePaywallData(from: config)
        let buttonStyle = payloadDTO?.buyButtonStyle
        return PaywallViewModel(
            iconName: payloadDTO?.iconName ?? Image.Gallery.Name.duck,
            description: payloadDTO?.description ?? "Please, subscribe!",
            buyActionTitle: payloadDTO?.buyButtonText ?? "Get premium access",
            restoreActionTitle: "Restore purchases",
            productModels: createPaywallModels(for: products),
            backgroundColor: getColor(for: payloadDTO?.backgroundColor) ?? Color.Palette.accent,
            textColor: getColor(for: payloadDTO?.textColor) ?? Color.Palette.accentContent,
            buyButtonStyle: .init(
                buttonColor: getColor(for: buttonStyle?.buttonColor) ?? Color.Palette.accentContent,
                buttonTextColor: getColor(for: buttonStyle?.buttonTextColor) ?? Color.Palette.accent
            )
        )
    }
    
    func decodePaywallData(from parameters: [String: Any]?) -> PaywallDataDTO? {
        guard
            let parameters = parameters,
            let data = try? JSONSerialization.data(withJSONObject: parameters)
        else {
            return nil
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try? decoder.decode(PaywallDataDTO.self, from: data)
    }
    
    func createPaywallModels(for products: [AdaptyPaywallProduct]) -> [ProductItemModel] {
        products.compactMap { product in
            guard
                let priceString = product.localizedPrice,
                let periodString = product.localizedSubscriptionPeriod
            else { return nil }
            
            return .init(
                id: product.vendorProductId,
                priceString: priceString,
                period: periodString,
                introductoryDiscount: getIntroductoryDiscount(for: product)
            )
        }
    }
    
    func getColor(for hexString: String?) -> Color? {
        guard let hexString = hexString else { return nil }
        return Color(hex: hexString)
    }
    
    func getIntroductoryDiscount(for product: AdaptyPaywallProduct) -> IntroductoryDiscountModel? {
        guard
            case .eligible = product.introductoryOfferEligibility,
            let discount = product.introductoryDiscount,
            let localizedPeriod = discount.localizedSubscriptionPeriod,
            let localizedPrice = discount.localizedPrice
        else {
            return nil
        }
        let paymentMode: String
        switch discount.paymentMode {
        case .freeTrial: paymentMode = "Free trial"
        case .payAsYouGo: paymentMode = "Pay as you go"
        case .payUpFront: paymentMode = "Pay upfront"
        case .unknown: paymentMode = ""
        }
        return .init(
            localizedPeriod: localizedPeriod,
            localizedPrice: localizedPrice,
            paymentMode: paymentMode
        )
    }
}
