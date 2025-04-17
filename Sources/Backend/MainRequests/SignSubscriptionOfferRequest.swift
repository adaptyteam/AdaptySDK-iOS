//
//  SignSubscriptionOfferRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.09.2022.
//

import Foundation

private struct SignSubscriptionOfferRequest: HTTPRequestWithDecodableResponse {
    typealias ResponseBody = Backend.Response.Data<AdaptySubscriptionOffer.Signature>

    let endpoint = HTTPEndpoint(
        method: .get,
        path: "/sdk/in-apps/apple/subscription-offer/sign/"
    )
    let headers: HTTPHeaders
    let queryItems: QueryItems
    let stamp = Log.stamp

    init(vendorProductId: String, offerId: String, profileId: String) {
        headers = HTTPHeaders().setBackendProfileId(profileId)

        queryItems = QueryItems()
            .setBackendProfileId(profileId)
            .setVendorProductId(vendorProductId)
            .setOfferId(offerId)
    }
}

extension Backend.MainExecutor {
    func signSubscriptionOffer(
        profileId: String,
        vendorProductId: String,
        offerId: String
    ) async throws -> AdaptySubscriptionOffer.Signature {
        let request = SignSubscriptionOfferRequest(
            vendorProductId: vendorProductId,
            offerId: offerId,
            profileId: profileId
        )
        let response = try await perform(
            request,
            requestName: .signSubscriptionOffer,
            logParams: [
                "product_id": vendorProductId,
                "discount_id": offerId,
            ]
        )

        return response.body.value
    }
}
