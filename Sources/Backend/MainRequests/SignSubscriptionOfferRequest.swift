//
//  SignSubscriptionOfferRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.09.2022.
//

import Foundation

private struct SignSubscriptionOfferRequest: HTTPRequestWithDecodableResponse {
    typealias ResponseBody = Backend.Response.ValueOfData<AdaptyProductDiscount.Signature>

    let endpoint = HTTPEndpoint(
        method: .get,
        path: "/sdk/in-apps/apple/subscription-offer/sign/"
    )
    let headers: HTTPHeaders
    let queryItems: QueryItems
    let stamp = Log.stamp

    init(vendorProductId: String, discountId: String, profileId: String) {
        headers = HTTPHeaders().setBackendProfileId(profileId)

        queryItems = QueryItems()
            .setBackendProfileId(profileId)
            .setVendorProductId(vendorProductId)
            .setDiscountId(discountId)
    }
}

extension Backend.MainExecutor {
    func performSignSubscriptionOfferRequest(
        profileId: String,
        vendorProductId: String,
        discountId: String
    ) async throws -> AdaptyProductDiscount.Signature {
        let request = SignSubscriptionOfferRequest(
            vendorProductId: vendorProductId,
            discountId: discountId,
            profileId: profileId
        )
        let response = try await perform(
            request,
            requestName: .signSubscriptionOffer,
            logParams: [
                "product_id": vendorProductId,
                "discount_id": discountId,
            ]
        )

        return response.body.value
    }
}
