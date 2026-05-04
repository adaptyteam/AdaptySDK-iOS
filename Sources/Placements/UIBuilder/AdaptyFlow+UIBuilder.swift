//
//  AdaptyFlow+UIBuilder.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.04.2026.
//

import AdaptyUIBuilder
import Foundation

extension AdaptyFlow {
    func asUIBuilderFlow() -> VC.FlowConstants {
        .init(
            placementId: placement.id,
            variationId: variationId,
            abTestName: placement.abTestName,
            name: name,
            products: paywalls.flatMap { $0.asUIBuilderFlowProducts() }
        )
    }
}

private extension AdaptyFlowPaywall {
    func asUIBuilderFlowProducts() -> [VC.FlowConstants.ProductConstants] {
        products.compactMap { product in
            guard let flowProductId = product.flowProductId else { return nil }

            return VC.FlowConstants.ProductConstants(
                flowProductId: flowProductId,
                adaptyProductId: product.adaptyProductId,
                adaptyAccessLevelId: product.productInfo.accessLevelId,
                adaptyProductType: product.productInfo.period.rawValue,
                paywallVariationId: variationId,
                paywallName: name
            )
        }
    }
}

