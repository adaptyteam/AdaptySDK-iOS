//
//  SetTransactionVariationIdRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2022.
//

import Foundation

private struct SetTransactionVariationIdRequest: HTTPEncodableRequest {
    typealias Result = HTTPEmptyResponse.Result

    let endpoint = HTTPEndpoint(
        method: .post,
        path: "/sdk/in-apps/transaction-variation-id/"
    )
    let headers: Headers
    let transactionId: String
    let variationId: String

    init(profileId: String, transactionId: String, variationId: String) {
        headers = Headers().setBackendProfileId(profileId)
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

extension HTTPSession {
    func performSetTransactionVariationIdRequest(
        profileId: String,
        transactionId: String,
        variationId: String,
        _ completion: AdaptyErrorCompletion?
    ) {
        let request = SetTransactionVariationIdRequest(
            profileId: profileId,
            transactionId: transactionId,
            variationId: variationId
        )
        
        perform(
            request,
            logName: "set_variation_id",
            logParams: [
                "transaction_id": .value(transactionId),
                "variation_id": .value(variationId),
            ]
        ) { (result: SetTransactionVariationIdRequest.Result) in
            switch result {
            case let .failure(error):
                completion?(error.asAdaptyError)
            case .success:
                completion?(nil)
            }
        }
    }
}
