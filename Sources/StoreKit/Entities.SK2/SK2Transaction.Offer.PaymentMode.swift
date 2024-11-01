//
//  SK2Transaction.Offer.PaymentMode.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2024
//

#if compiler(>=5.9.2) && (!os(visionOS) || compiler(>=5.10))

    import StoreKit

    @available(iOS 17.2, macOS 14.2, tvOS 17.2, watchOS 10.2, visionOS 1.1, *)
    extension SK2Transaction.Offer.PaymentMode {
        var asPaymentMode: AdaptySubscriptionOffer.PaymentMode {
            switch self {
            case .payAsYouGo:
                .payAsYouGo
            case .payUpFront:
                .payUpFront
            case .freeTrial:
                .freeTrial
            default:
                .unknown
            }
        }
    }
#endif
