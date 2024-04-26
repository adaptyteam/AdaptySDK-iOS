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
        Adapty.getPaywall(placementId: "example_ab_test") { [weak self] result in
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

        Adapty.getPaywallProducts(paywall: currentPaywall) { [weak self] result in
            switch result {
            case let .success(products):
                self?.updateProducts(products, remoteConfig: remoteConfig, eligibilities: nil)

                Adapty.getProductsIntroductoryOfferEligibility(products: products) { result in
                    switch result {
                    case let .success(eligibilities):
                        self?.updateProducts(products, remoteConfig: remoteConfig, eligibilities: eligibilities)
                        completion?(nil)
                    case let .failure(error):
                        completion?(error)
                    }
                }
            case let .failure(error):
                completion?(error)
            }
        }
    }

    private func updateProducts(_ products: [AdaptyPaywallProduct],
                                remoteConfig: [String: Any]?,
                                eligibilities: [String: AdaptyEligibility]?) {
        paywallProducts = products
        paywallViewModel = model(for: remoteConfig, products: products, eligibilities: eligibilities)
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
    func model(for config: [String: Any]?,
               products: [AdaptyPaywallProduct],
               eligibilities: [String: AdaptyEligibility]?) -> PaywallViewModel? {
        guard !products.isEmpty else { return nil }
        let payloadDTO = decodePaywallData(from: config)
        let buttonStyle = payloadDTO?.buyButtonStyle
        return PaywallViewModel(
            iconName: payloadDTO?.iconName ?? Image.Gallery.Name.duck,
            description: payloadDTO?.description ?? "Please, subscribe!",
            buyActionTitle: payloadDTO?.buyButtonText ?? "Get premium access",
            restoreActionTitle: "Restore purchases",
            productModels: createPaywallModels(for: products, eligibilities: eligibilities),
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

    func createPaywallModels(for products: [AdaptyPaywallProduct],
                             eligibilities: [String: AdaptyEligibility]?) -> [ProductItemModel] {
        products.compactMap { product in
            guard
                let priceString = product.localizedPrice,
                let periodString = product.localizedSubscriptionPeriod
            else { return nil }

            return .init(
                id: product.vendorProductId,
                priceString: priceString,
                period: periodString,
                introductoryDiscount: getIntroductoryDiscount(for: product,
                                                              introductoryOfferEligibility: eligibilities?[product.vendorProductId])
            )
        }
    }

    func getColor(for hexString: String?) -> Color? {
        guard let hexString = hexString else { return nil }
        return Color(hex: hexString)
    }

    func getIntroductoryDiscount(for product: AdaptyPaywallProduct,
                                 introductoryOfferEligibility: AdaptyEligibility?) -> IntroductoryDiscountModel? {
        guard
            case .eligible = introductoryOfferEligibility,
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
