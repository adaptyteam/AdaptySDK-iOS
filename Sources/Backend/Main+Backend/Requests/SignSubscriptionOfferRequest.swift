//
//  SignSubscriptionOfferRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.09.2022.
//

import Foundation

private struct SignSubscriptionOfferRequest: BackendRequest {
    let endpoint = HTTPEndpoint(
        method: .get,
        path: "/sdk/in-apps/apple/subscription-offer/sign/"
    )
    let headers: HTTPHeaders
    let queryItems: QueryItems
    let stamp = Log.stamp
    let requestName = BackendRequestName.signSubscriptionOffer
    let logParams: EventParameters?

    init(vendorProductId: String, offerId: String, userId: AdaptyUserId) {
        headers = HTTPHeaders()
            .setUserProfileId(userId)

        queryItems = QueryItems()
            .setUserProfileId(userId)
            .setVendorProductId(vendorProductId)
            .setOfferId(offerId)

        logParams = [
            "product_id": vendorProductId,
            "discount_id": offerId
        ]
    }
}

private typealias ResponseBody = Backend.Response.Data<AdaptySubscriptionOffer.Signature>

extension Backend.MainExecutor {
    func signSubscriptionOffer(
        userId: AdaptyUserId,
        vendorProductId: String,
        offerId: String
    ) async throws(HTTPError) -> AdaptySubscriptionOffer.Signature {
        let request = SignSubscriptionOfferRequest(
            vendorProductId: vendorProductId,
            offerId: offerId,
            userId: userId
        )
        let response: HTTPResponse<ResponseBody> = try await perform(request)
        return response.body.value
    }
}
