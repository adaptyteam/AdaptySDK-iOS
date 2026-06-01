//
//  Dev_PreviewProduct+ProductConstants.swift
//  AdaptyDeveloperTools
//

import AdaptyUIBuilder
import Foundation

extension Dev_PreviewProduct {
    func asProductConstants() -> VC.FlowConstants.ProductConstants {
        if let title = localizedTitle,
           let description = localizedDescription,
           let price {
            return .init(
                flowProductId: flowProductId,
                adaptyProductId: adaptyProductId,
                adaptyAccessLevelId: adaptyAccessLevelId,
                adaptyProductType: adaptyProductType,
                paywallVariationId: paywallVariationId,
                paywallName: paywallName,
                localizedDescription: description,
                localizedTitle: title,
                isFamilyShareable: isFamilyShareable,
                regionCode: regionCode,
                price: .init(
                    amount: price.amount,
                    currencyCode: price.currencyCode,
                    currencySymbol: price.currencySymbol,
                    localizedString: price.localizedString
                ),
                subscription: subscription.map { sub in
                    .init(
                        groupIdentifier: sub.groupIdentifier,
                        period: .init(
                            unit: sub.period.unit,
                            numberOfUnits: sub.period.numberOfUnits
                        ),
                        localizedPeriod: sub.localizedPeriod,
                        offer: sub.offer.map { offer in
                            .init(
                                id: offer.id,
                                type: offer.type,
                                price: offer.price.map { p in
                                    .init(
                                        amount: p.amount,
                                        currencyCode: p.currencyCode,
                                        currencySymbol: p.currencySymbol,
                                        localizedString: p.localizedString
                                    )
                                },
                                paymentMode: offer.paymentMode,
                                period: .init(
                                    unit: offer.period.unit,
                                    numberOfUnits: offer.period.numberOfUnits
                                ),
                                numberOfPeriods: offer.numberOfPeriods,
                                localizedPeriod: offer.localizedPeriod,
                                localizedNumberOfPeriods: offer.localizedNumberOfPeriods
                            )
                        }
                    )
                }
            )
        } else {
            return .init(
                flowProductId: flowProductId,
                adaptyProductId: adaptyProductId,
                adaptyAccessLevelId: adaptyAccessLevelId,
                adaptyProductType: adaptyProductType,
                paywallVariationId: paywallVariationId,
                paywallName: paywallName
            )
        }
    }
}

extension Array where Element == Dev_PreviewProduct {
    func asProductConstants() -> [VC.FlowConstants.ProductConstants] {
        map { $0.asProductConstants() }
    }
}
