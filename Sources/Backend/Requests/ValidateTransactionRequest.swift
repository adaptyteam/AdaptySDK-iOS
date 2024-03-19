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

    let requestSource: RequestSource

    init(profileId: String, requestSource: RequestSource) {
        headers = Headers().setBackendProfileId(profileId)
        self.profileId = profileId
        self.requestSource = requestSource
    }

    enum CodingKeys: String, CodingKey {
        case profileId = "profile_id"
        case originalTransactionId = "original_transaction_id"
        case requestSource = "request_source"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Backend.CodingKeys.self)
        var dataObject = container.nestedContainer(keyedBy: Backend.CodingKeys.self, forKey: .data)
        try dataObject.encode("adapty_purchase_app_store_original_transaction_id_validation_result", forKey: .type)
        switch requestSource {
        case let .restore(originalTransactionId):
            var attributesObject = dataObject.nestedContainer(keyedBy: CodingKeys.self, forKey: .attributes)
            try attributesObject.encode(profileId, forKey: .profileId)
            try attributesObject.encode(Adapty.ValidatePurchaseReason.restoreRawString, forKey: .requestSource)
            try attributesObject.encode(originalTransactionId, forKey: .originalTransactionId)
        case let .other(purchasedTransaction, reason):
            try dataObject.encode(purchasedTransaction, forKey: .attributes)
            var attributesObject = dataObject.nestedContainer(keyedBy: CodingKeys.self, forKey: .attributes)
            try attributesObject.encode(profileId, forKey: .profileId)
            try attributesObject.encode(reason.rawString, forKey: .requestSource)
        }
    }

    enum RequestSource {
        case restore(String)
        case other(PurchasedTransaction, reason: Adapty.ValidatePurchaseReason)
    }
}

extension HTTPSession {
    private func perform(_ request: ValidateTransactionRequest, _ logParams: EventParameters, _ completion: @escaping AdaptyResultCompletion<VH<AdaptyProfile>>) -> HTTPCancelable {
        perform(request, logName: "validate_transaction", logParams: logParams) { (result: ValidateTransactionRequest.Result) in
            switch result {
            case let .failure(error):
                completion(.failure(error.asAdaptyError))
            case let .success(response):
                completion(.success(VH(response.body.value, hash: response.headers.getBackendResponseHash())))
            }
        }
    }

    func performSyncTransactionRequest(
        profileId: String,
        originalTransactionId: String,
        _ completion: @escaping AdaptyResultCompletion<VH<AdaptyProfile>>
    ) {
        let request = ValidateTransactionRequest(
            profileId: profileId,
            requestSource: .restore(originalTransactionId)
        )
        let logParams: EventParameters = [
            "original_transaction_id": .valueOrNil(originalTransactionId),
            "request_source": .value(Adapty.ValidatePurchaseReason.restoreRawString),
        ]
        _ = perform(request, logParams, completion)
    }

    func performValidateTransactionRequest(
        profileId: String,
        purchasedTransaction: PurchasedTransaction,
        reason: Adapty.ValidatePurchaseReason,
        _ completion: @escaping AdaptyResultCompletion<VH<AdaptyProfile>>
    ) {
        let request = ValidateTransactionRequest(
            profileId: profileId,
            requestSource: .other(purchasedTransaction, reason: reason)
        )
        let logParams: EventParameters = [
            "product_id": .value(purchasedTransaction.vendorProductId),
            "original_transaction_id": .valueOrNil(purchasedTransaction.originalTransactionId),
            "transaction_id": .valueOrNil(purchasedTransaction.transactionId),
            "variation_id": .valueOrNil(purchasedTransaction.productVariationId),
            "variation_id_persistent": .valueOrNil(purchasedTransaction.persistentProductVariationId),
            "promotional_offer_id": .valueOrNil(purchasedTransaction.subscriptionOffer?.id),
            "environment": .valueOrNil(purchasedTransaction.environment),
            "request_source": .value(reason.rawString),
        ]
        _ = perform(request, logParams, completion)
    }
}

private extension Adapty.ValidatePurchaseReason {
    static let restoreRawString = "restore"
    var rawString: String {
        switch self {
        case .setVariation: "set_variation"
        case .observing: "observing"
        case .purchasing: "purchasing"
        }
    }
}
