//
//  Dev_AdaptyUIConfiguration.swift
//  AdaptyDeveloperTools
//
//  Created by Aleksey Goncharov on 20.05.2024.
//

import AdaptyUIBuilder
import Foundation

public struct Dev_AdaptyUIConfiguration {
    typealias Wrapped = AdaptyUIConfiguration
    let wrapped: Wrapped
    let previewProducts: [Dev_PreviewProduct]
    public let json: String
}

public extension Dev_AdaptyUIConfiguration {
    static func create(
        main: String,
        templates: String? = nil,
        navigators: [String: String]? = nil,
        contents: [AdaptyUISchema.ExampleContent],
        script: String? = nil,
        startScreenName: String?,
        environment: Dev_PreviewEnvironment = .empty
    ) throws -> Self {
        let json = try AdaptyUISchema.createJson(
            main: main,
            templates: templates,
            navigators: navigators,
            contents: contents,
            script: script,
            startScreenName: startScreenName
        )

        return try create(json: json, environment: environment)
    }

    static func create(
        json: String,
        environment: Dev_PreviewEnvironment = .empty
    ) throws -> Self {
        let uuid = UUID().uuidString.lowercased()
        let schema = try AdaptyUISchema(from: json)
        let configuration = try schema.extractUIConfiguration(
            id: uuid,
            envoriment: .init(
                sdkVersion: environment.sdkVersion,
                osName: environment.osName,
                osVersion: environment.osVersion,
                deviceModel: environment.deviceModel,
                appBundleId: environment.appBundleId,
                appVersion: environment.appVersion,
                appBuild: environment.appBuild,
                appCurrentLocale: environment.appCurrentLocale,
                userLocales: environment.userLocales,
                userUses24HourClock: environment.userUses24HourClock,
                flow: .init(
                    placementId: environment.placementId,
                    variationId: environment.variationId,
                    abTestName: environment.abTestName,
                    name: environment.placementName,
                    products: environment.products.map { product in
                        if let title = product.localizedTitle,
                           let description = product.localizedDescription,
                           let price = product.price {
                            return .init(
                                flowProductId: product.flowProductId,
                                adaptyProductId: product.adaptyProductId,
                                adaptyAccessLevelId: product.adaptyAccessLevelId,
                                adaptyProductType: product.adaptyProductType,
                                paywallVariationId: product.paywallVariationId,
                                paywallName: product.paywallName,
                                localizedDescription: description,
                                localizedTitle: title,
                                isFamilyShareable: product.isFamilyShareable,
                                regionCode: product.regionCode,
                                price: .init(
                                    amount: price.amount,
                                    currencyCode: price.currencyCode,
                                    currencySymbol: price.currencySymbol,
                                    localizedString: price.localizedString
                                ),
                                subscription: product.subscription.map { sub in
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
                                flowProductId: product.flowProductId,
                                adaptyProductId: product.adaptyProductId,
                                adaptyAccessLevelId: product.adaptyAccessLevelId,
                                adaptyProductType: product.adaptyProductType,
                                paywallVariationId: product.paywallVariationId,
                                paywallName: product.paywallName
                            )
                        }
                    }
                )
            )
        )
        return .init(
            wrapped: configuration,
            previewProducts: environment.products,
            json: json
        )
    }
}

