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

    let purchaseProductInfo: PurchaseProductInfo

    init(profileId: String, purchaseProductInfo: PurchaseProductInfo) {
        headers = Headers().setBackendProfileId(profileId)
        self.profileId = profileId
        self.purchaseProductInfo = purchaseProductInfo
    }

    enum CodingKeys: String, CodingKey {
        case profileId = "profile_id"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Backend.CodingKeys.self)
        var dataObject = container.nestedContainer(keyedBy: Backend.CodingKeys.self, forKey: .data)
        try dataObject.encode("adapty_purchase_app_store_original_transaction_id_validation_result", forKey: .type)

        guard purchaseProductInfo.originalTransactionId != nil else {
            throw EncodingError.invalidValue(purchaseProductInfo, EncodingError.Context(codingPath: dataObject.codingPath + [Backend.CodingKeys.attributes, PurchaseProductInfo.CodingKeys.originalTransactionId], debugDescription: "originalTransactionId is nil "))
        }

        try dataObject.encode(purchaseProductInfo, forKey: .attributes)

        var attributesObject = dataObject.nestedContainer(keyedBy: CodingKeys.self, forKey: .attributes)
        try attributesObject.encode(profileId, forKey: .profileId)
    }
}

extension HTTPSession {
    func performValidateTransactionRequest(profileId: String,
                                           purchaseProductInfo: PurchaseProductInfo,
                                           _ completion: @escaping AdaptyResultCompletion<VH<AdaptyProfile>>) {
        let request = ValidateTransactionRequest(profileId: profileId,
                                                 purchaseProductInfo: purchaseProductInfo)
        let logParams: EventParameters = [
            "product_id": .value(purchaseProductInfo.vendorProductId),
            "original_transaction_id": .valueOrNil(purchaseProductInfo.originalTransactionId),
            "transaction_id": .valueOrNil(purchaseProductInfo.transactionId),
            "variation_id": .valueOrNil(purchaseProductInfo.productVariationId),
            "variation_id_persistent": .valueOrNil(purchaseProductInfo.persistentProductVariationId),
            "promotional_offer_id": .valueOrNil(purchaseProductInfo.promotionalOfferId),
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
