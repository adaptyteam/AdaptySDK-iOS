//
//  SetTransactionVariationIdRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2022.
//

import Foundation

private struct SetTransactionVariationIdRequest: HTTPEncodableRequest {
    let endpoint = HTTPEndpoint(
        method: .post,
        path: "/sdk/purchase/transaction/variation-id/set/"
    )
    let headers: HTTPHeaders
    let stamp = Log.stamp

    let transactionId: String
    let variationId: String

    init(profileId: String, transactionId: String, variationId: String) {
        headers = HTTPHeaders().setBackendProfileId(profileId)
        self.transactionId = transactionId
        self.variationId = variationId
    }

    enum CodingKeys: String, CodingKey {
        case transactionId = "transaction_id"
        case variationId = "variation_id"
    }

    func encode(to encoder: Encoder) throws {
        var container = try encoder.backendContainer(
            type: "adapty_analytics_transaction_variation_id",
            keyedBy: CodingKeys.self
        )
        try container.encode(transactionId, forKey: .transactionId)
        try container.encode(variationId, forKey: .variationId)
    }
}

extension Backend.MainExecutor {
    func performSetTransactionVariationIdRequest(
        profileId: String,
        transactionId: String,
        variationId: String
    ) async throws {
        let request = SetTransactionVariationIdRequest(
            profileId: profileId,
            transactionId: transactionId,
            variationId: variationId
        )

        let _: HTTPEmptyResponse = try await perform(
            request,
            requestName: .setTransactionVariationId,
            logParams: [
                "transaction_id": transactionId,
                "variation_id": variationId,
            ]
        )
    }
}
