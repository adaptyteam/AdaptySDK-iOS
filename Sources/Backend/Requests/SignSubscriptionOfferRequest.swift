//
//  SignSubscriptionOfferRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.09.2022.
//

import Foundation

private struct SignSubscriptionOfferRequest: HTTPRequestWithDecodableResponse {
    typealias ResponseBody = Backend.Response.Body<SignSubscriptionOfferResponse>

    let endpoint = HTTPEndpoint(
        method: .get,
        path: "/sdk/in-apps/apple/subscription-offer/sign/"
    )
    let headers: Headers
    let queryItems: QueryItems

    init(vendorProductId: String, discountId: String, profileId: String) {
        headers = Headers().setBackendProfileId(profileId)

        queryItems = QueryItems()
            .setBackendProfileId(profileId)
            .setVendorProductId(vendorProductId)
            .setDiscountId(discountId)
    }
}

extension HTTPSession {
    func performSignSubscriptionOfferRequest(
        profileId: String,
        vendorProductId: String,
        discountId: String,
        _ completion: @escaping AdaptyResultCompletion<SignSubscriptionOfferResponse>
    ) {
        let request = SignSubscriptionOfferRequest(
            vendorProductId: vendorProductId,
            discountId: discountId,
            profileId: profileId
        )
        perform(
            request,
            logName: "sign_offer",
            logParams: [
                "product_id": .value(vendorProductId),
                "discount_id": .value(discountId),
            ]
        ) { (result: SignSubscriptionOfferRequest.Result) in
            switch result {
            case let .failure(error):
                completion(.failure(error.asAdaptyError))
            case let .success(response):
                completion(.success(response.body.value))
            }
        }
    }
}
