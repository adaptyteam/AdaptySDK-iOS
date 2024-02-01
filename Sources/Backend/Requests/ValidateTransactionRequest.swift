//
//  ValidateTransactionRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 30.05.2023
//

import Foundation

private struct ValidateTransactionRequest: HTTPEncodableRequest, HTTPRequestWithDecodableResponse {
    typealias ResponseBody = Backend.Response.Body<AdaptyProfile>

    let endpoint = HTTPEndpoint(
        method: .post,
        path: "/sdk/purchase/app-store/original-transaction-id/validate/"
    )
    let headers: Headers
    let profileId: String

    let purchasedTransaction: PurchasedTransaction

    init(profileId: String, purchasedTransaction: PurchasedTransaction) {
        headers = Headers().setBackendProfileId(profileId)
        self.profileId = profileId
        self.purchasedTransaction = purchasedTransaction
    }

    enum CodingKeys: String, CodingKey {
        case profileId = "profile_id"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Backend.CodingKeys.self)
        var dataObject = container.nestedContainer(keyedBy: Backend.CodingKeys.self, forKey: .data)
        try dataObject.encode("adapty_purchase_app_store_original_transaction_id_validation_result", forKey: .type)

        try dataObject.encode(purchasedTransaction, forKey: .attributes)

        var attributesObject = dataObject.nestedContainer(keyedBy: CodingKeys.self, forKey: .attributes)
        try attributesObject.encode(profileId, forKey: .profileId)
    }
}

extension HTTPSession {
    func performValidateTransactionRequest(profileId: String,
                                           purchasedTransaction: PurchasedTransaction,
                                           _ completion: @escaping AdaptyResultCompletion<VH<AdaptyProfile>>) {
        let request = ValidateTransactionRequest(profileId: profileId,
                                                 purchasedTransaction: purchasedTransaction)
        let logParams: EventParameters = [
            "product_id": .value(purchasedTransaction.vendorProductId),
            "original_transaction_id": .valueOrNil(purchasedTransaction.originalTransactionId),
            "transaction_id": .valueOrNil(purchasedTransaction.transactionId),
            "variation_id": .valueOrNil(purchasedTransaction.productVariationId),
            "variation_id_persistent": .valueOrNil(purchasedTransaction.persistentProductVariationId),
            "promotional_offer_id": .valueOrNil(purchasedTransaction.subscriptionOffer?.id),
            "environment": .valueOrNil(purchasedTransaction.environment),
        ]
        perform(request, logName: "validate_transaction", logParams: logParams) { (result: ValidateTransactionRequest.Result) in
            switch result {
            case let .failure(error):
                completion(.failure(error.asAdaptyError))
            case let .success(response):
                completion(.success(VH(response.body.value, hash: response.headers.getBackendResponseHash())))
            }
        }
    }
}
